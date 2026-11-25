import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:opentunemobile/core/services/storage_service.dart';

void main() {
  test('extracts object path from a project public URL', () {
    expect(
      StorageService.objectPathFromPublicUrl(
        'https://jxglsxjwrhiugtxmvaxa.supabase.co/storage/v1/object/public/covers/user-1/songs/cover.jpg',
        StorageBucket.covers,
      ),
      'user-1/songs/cover.jpg',
    );
  });

  test('rejects a URL for a different bucket', () {
    expect(
      () => StorageService.objectPathFromPublicUrl(
        'https://jxglsxjwrhiugtxmvaxa.supabase.co/storage/v1/object/public/audio_files/user-1/song.mp3',
        StorageBucket.covers,
      ),
      throwsFormatException,
    );
  });

  test('uses allowlisted audio extensions and validates file signatures', () {
    expect(
      StorageService.validateFileContent(
        Uint8List.fromList(
            [0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x41, 0x56, 0x45]),
        StorageBucket.audioFiles,
        'track.WAV',
      ),
      'audio/wav',
    );
    expect(
      () => StorageService.validateFileContent(
        Uint8List.fromList([1, 2, 3]),
        StorageBucket.audioFiles,
        'track.mp3',
      ),
      throwsFormatException,
    );
  });
}
