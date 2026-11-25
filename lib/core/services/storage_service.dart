import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_config.dart';
import '../../features/song_artist_album/repositories/repository_guard.dart';

enum StorageBucket {
  covers,
  audioFiles;

  String get bucketName => switch (this) {
        StorageBucket.covers => 'covers',
        StorageBucket.audioFiles => 'audio_files',
      };
}

enum StorageCategory { songs, albums }

class StorageService {
  Future<String> uploadCover(
    Uint8List bytes,
    String fileName, {
    required StorageCategory category,
    int? albumId,
  }) {
    final extension = _extension(fileName, const {'jpg', 'jpeg', 'png', 'webp'});
    final contentType =
        validateFileContent(bytes, StorageBucket.covers, fileName);
    final userId = requireUserId();
    if (albumId != null && albumId < 1) {
      throw ArgumentError.value(albumId, 'albumId', 'ID album harus positif.');
    }
    final albumFolder = category == StorageCategory.albums && albumId != null
        ? '$albumId/'
        : '';
    final path =
        '$userId/${category.name}/$albumFolder${_uniqueName(extension)}';
    return _upload(StorageBucket.covers, path, bytes, contentType);
  }

  Future<String> uploadAudio(
    Uint8List bytes,
    String fileName, {
    required StorageCategory category,
    int? albumId,
    int? trackNumber,
  }) {
    final extension = _extension(fileName, const {'mp3', 'm4a', 'wav'});
    final contentType =
        validateFileContent(bytes, StorageBucket.audioFiles, fileName);
    final userId = requireUserId();
    if (category == StorageCategory.albums &&
        (albumId == null || albumId < 1)) {
      throw ArgumentError.value(
          albumId, 'albumId', 'ID album wajib dan harus positif.');
    }
    if (category == StorageCategory.songs && albumId != null) {
      throw ArgumentError.value(
          albumId, 'albumId', 'Single tidak boleh memiliki ID album.');
    }
    if (trackNumber != null && trackNumber < 1) {
      throw ArgumentError.value(
          trackNumber, 'trackNumber', 'Nomor track harus positif.');
    }
    final folder =
        category == StorageCategory.albums ? 'albums/$albumId/' : 'songs/';
    final trackPrefix = trackNumber == null
        ? ''
        : 'track_${trackNumber.toString().padLeft(3, '0')}_';
    final path = '$userId/$folder$trackPrefix${_uniqueName(extension)}';
    return _upload(StorageBucket.audioFiles, path, bytes, contentType);
  }

  String getPublicUrl(StorageBucket bucket, String path) {
    _validateOwnedPath(path);
    return SupabaseConfig.client.storage
        .from(bucket.bucketName)
        .getPublicUrl(path);
  }

  Future<void> removeObjects(
      StorageBucket bucket, List<String> pathsOrUrls) async {
    if (pathsOrUrls.isEmpty) return;
    final userId = requireUserId();
    final paths = pathsOrUrls.map((value) {
      final uri = Uri.tryParse(value);
      final path = uri?.hasAuthority == true
          ? objectPathFromPublicUrl(value, bucket)
          : value;
      _validateOwnedPath(path, userId: userId);
      return path;
    }).toList();
    await SupabaseConfig.client.storage.from(bucket.bucketName).remove(paths);
  }

  static String objectPathFromPublicUrl(
      String publicUrl, StorageBucket bucket) {
    final uri = Uri.tryParse(publicUrl);
    final projectUri = Uri.parse(SupabaseConfig.supabaseUrl);
    if (uri == null || !uri.hasAuthority || uri.origin != projectUri.origin) {
      throw const FormatException(
          'URL Storage bukan berasal dari project Supabase ini.');
    }
    final segments = uri.pathSegments;
    const prefix = ['storage', 'v1', 'object', 'public'];
    if (segments.length < prefix.length + 2 ||
        !_hasPrefix(segments, prefix) ||
        segments[prefix.length] != bucket.bucketName) {
      throw FormatException(
          'URL bukan Public URL untuk bucket ${bucket.bucketName}.');
    }
    final objectSegments = segments.skip(prefix.length + 1).toList();
    if (objectSegments.isEmpty || objectSegments.any((part) => part.isEmpty)) {
      throw const FormatException('URL Storage tidak berisi object path yang valid.');
    }
    return objectSegments.join('/');
  }

  static String validateFileContent(
    Uint8List bytes,
    StorageBucket bucket,
    String fileName,
  ) {
    final extensions = bucket == StorageBucket.covers
        ? const {'jpg', 'jpeg', 'png', 'webp'}
        : const {'mp3', 'm4a', 'wav'};
    final extension = _extension(fileName, extensions);
    _validateBytes(bytes);
    final valid = switch (extension) {
      'jpg' || 'jpeg' => _startsWith(bytes, const [0xff, 0xd8, 0xff]),
      'png' => _startsWith(
          bytes, const [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
      'webp' => _asciiAt(bytes, 0, 'RIFF') && _asciiAt(bytes, 8, 'WEBP'),
      'wav' => _asciiAt(bytes, 0, 'RIFF') && _asciiAt(bytes, 8, 'WAVE'),
      'm4a' => _asciiAt(bytes, 4, 'ftyp'),
      'mp3' => _asciiAt(bytes, 0, 'ID3') ||
          (bytes.length > 1 && bytes[0] == 0xff && (bytes[1] & 0xe0) == 0xe0),
      _ => false,
    };
    if (!valid) {
      throw FormatException(
          'Isi file tidak sesuai dengan ekstensi .$extension.');
    }
    return bucket == StorageBucket.covers
        ? _imageMime(extension)
        : _audioMime(extension);
  }

  Future<String> _upload(
    StorageBucket bucket,
    String path,
    Uint8List bytes,
    String contentType,
  ) async {
    final publicUrl = getPublicUrl(bucket, path);
    await SupabaseConfig.client.storage.from(bucket.bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );
    return publicUrl;
  }

  static void _validateOwnedPath(String path, {String? userId}) {
    final ownerId = userId ?? requireUserId();
    final segments = path.split('/');
    if (path.isEmpty ||
        path.startsWith('/') ||
        segments.first != ownerId ||
        segments.any((part) => part.isEmpty || part == '.' || part == '..')) {
      throw ArgumentError.value(
          path, 'path', 'Object path harus berada di folder UID aktif.');
    }
  }

  static void _validateBytes(Uint8List bytes) {
    if (bytes.isEmpty) throw ArgumentError('File tidak boleh kosong.');
  }

  static bool _startsWith(Uint8List bytes, List<int> signature) {
    if (bytes.length < signature.length) return false;
    for (var i = 0; i < signature.length; i++) {
      if (bytes[i] != signature[i]) return false;
    }
    return true;
  }

  static bool _asciiAt(Uint8List bytes, int offset, String signature) {
    if (bytes.length < offset + signature.length) return false;
    for (var i = 0; i < signature.length; i++) {
      if (bytes[offset + i] != signature.codeUnitAt(i)) return false;
    }
    return true;
  }

  static String _extension(String fileName, Set<String> allowed) {
    final extension =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    if (!allowed.contains(extension)) {
      throw ArgumentError.value(
          fileName, 'fileName', 'Format file tidak didukung.');
    }
    return extension;
  }

  static String _imageMime(String extension) => switch (extension) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => throw ArgumentError.value(extension, 'extension'),
      };

  static String _audioMime(String extension) => switch (extension) {
        'mp3' => 'audio/mpeg',
        'm4a' => 'audio/mp4',
        'wav' => 'audio/wav',
        _ => throw ArgumentError.value(extension, 'extension'),
      };

  static String _uniqueName(String extension) {
    final random =
        Random.secure().nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
    return '${DateTime.now().microsecondsSinceEpoch}_$random.$extension';
  }

  static bool _hasPrefix(List<String> value, List<String> prefix) =>
      prefix.asMap().entries.every((entry) => value[entry.key] == entry.value);
}
