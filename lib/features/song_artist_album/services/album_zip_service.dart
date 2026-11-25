import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/storage_service.dart';

class AlbumZipTrack {
  const AlbumZipTrack({
    required this.title,
    required this.bytes,
    required this.trackNumber,
    required this.fileName,
  });

  final String title;
  final Uint8List bytes;
  final int trackNumber;
  final String fileName;
}

class AlbumZipService {
  static const maxZipInputBytes = 50 * 1024 * 1024;
  static const maxExtractedAudioBytes = 250 * 1024 * 1024;
  static const maxAudioBytes = 50 * 1024 * 1024;
  static const maxTracks = 100;

  Future<List<AlbumZipTrack>> decode(Uint8List bytes) =>
      compute<Uint8List, List<Map<String, Object>>>(_decodeAlbumZip, bytes)
          .then((rows) => rows
              .map((row) => AlbumZipTrack(
                    title: row['title'] as String,
                    bytes: row['bytes'] as Uint8List,
                    trackNumber: row['trackNumber'] as int,
                    fileName: row['fileName'] as String,
                  ))
              .toList());
}

List<Map<String, Object>> _decodeAlbumZip(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > AlbumZipService.maxZipInputBytes) {
    throw const FormatException('ZIP harus berukuran 1–50 MiB.');
  }

  final archive =
      ZipDecoder().decodeBytes(bytes, verify: true, throwOnError: true);
  final candidates = <({ArchiveFile file, String name, int? prefix})>[];
  for (final file in archive.files) {
    if (!file.isFile || _isMetadata(file.name)) continue;
    final name = file.name.split(RegExp(r'[/\\]')).last;
    final extension =
        name.contains('.') ? name.split('.').last.toLowerCase() : '';
    if (!const {'mp3', 'm4a', 'wav'}.contains(extension)) continue;
    if (file.isSymbolicLink) {
      throw const FormatException(
          'ZIP memuat tautan simbolik audio yang tidak didukung.');
    }
    if (file.size <= 0 || file.size > AlbumZipService.maxAudioBytes) {
      throw FormatException(
          'Ukuran track "$name" tidak valid atau melebihi 50 MiB.');
    }
    candidates.add((file: file, name: name, prefix: _trackPrefix(name)));
  }

  if (candidates.isEmpty) {
    throw const FormatException('ZIP tidak berisi audio valid.');
  }
  if (candidates.length > AlbumZipService.maxTracks) {
    throw const FormatException(
        'ZIP melebihi batas ${AlbumZipService.maxTracks} track.');
  }
  final declaredBytes =
      candidates.fold<int>(0, (total, item) => total + item.file.size);
  if (declaredBytes > AlbumZipService.maxExtractedAudioBytes) {
    throw const FormatException(
        'Total audio hasil ekstraksi melebihi 250 MiB.');
  }

  final numbered = candidates.where((item) => item.prefix != null).toList();
  final prefixes = numbered.map((item) => item.prefix).toSet();
  if (prefixes.length != numbered.length) {
    throw const FormatException('Nomor track duplikat ditemukan di dalam ZIP.');
  }
  final allNumbered = numbered.length == candidates.length;
  final ordered = allNumbered
      ? (List.of(candidates)..sort((a, b) => a.prefix!.compareTo(b.prefix!)))
      : candidates;

  var actualBytes = 0;
  return ordered.asMap().entries.map((indexed) {
    final item = indexed.value;
    final data = Uint8List.fromList(item.file.content);
    if (data.length != item.file.size || data.isEmpty) {
      throw FormatException('Isi track "${item.name}" tidak utuh.');
    }
    actualBytes += data.length;
    if (actualBytes > AlbumZipService.maxExtractedAudioBytes) {
      throw const FormatException(
          'Total audio hasil ekstraksi melebihi 250 MiB.');
    }
    StorageService.validateFileContent(
        data, StorageBucket.audioFiles, item.name);
    final title = _title(item.name);
    if (title.isEmpty) {
      throw FormatException('Nama track "${item.name}" kosong.');
    }
    return <String, Object>{
      'title': title,
      'bytes': data,
      'trackNumber': allNumbered ? item.prefix! : indexed.key + 1,
      'fileName': item.name,
    };
  }).toList();
}

bool _isMetadata(String path) {
  final parts = path.split(RegExp(r'[/\\]'));
  return parts.any((part) =>
      part == '__MACOSX' || part.startsWith('._') || part.startsWith('.'));
}

int? _trackPrefix(String name) {
  final match = RegExp(r'^(\d+)\s*[-_. )]+\s*').firstMatch(name);
  if (match == null) return null;
  final number = int.tryParse(match.group(1)!);
  if (number == null || number < 1) {
    throw FormatException('Nomor track pada "$name" tidak valid.');
  }
  return number;
}

String _title(String name) {
  final withoutExtension = name.replaceFirst(RegExp(r'\.[^.]+$'), '');
  return withoutExtension
      .replaceFirst(RegExp(r'^\d+\s*[-_. )]+\s*'), '')
      .trim();
}
