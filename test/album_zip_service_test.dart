import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opentunemobile/features/song_artist_album/services/album_zip_service.dart';

Uint8List _zip(List<(String, List<int>)> entries) {
  final archive = Archive();
  for (final (name, bytes) in entries) {
    archive.addFile(ArchiveFile.bytes(name, bytes));
  }
  return ZipEncoder().encodeBytes(archive);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final service = AlbumZipService();
  final mp3 = [0x49, 0x44, 0x33, 0x00];

  test('sorts fully numbered tracks and uses their numeric prefixes', () async {
    final tracks = await service.decode(_zip([
      ('02 - Second.mp3', mp3),
      ('01 - First.mp3', mp3),
    ]));
    expect(tracks.map((track) => track.title), ['First', 'Second']);
    expect(tracks.map((track) => track.trackNumber), [1, 2]);
  });

  test('rejects duplicate numeric prefixes', () async {
    await expectLater(
      service.decode(_zip([
        ('01 - First.mp3', mp3),
        ('01 - Duplicate.mp3', mp3),
      ])),
      throwsFormatException,
    );
  });

  test('keeps archive order and numbers tracks sequentially when unnumbered',
      () async {
    final tracks = await service.decode(_zip([
      ('Second.mp3', mp3),
      ('First.mp3', mp3),
    ]));
    expect(tracks.map((track) => track.title), ['Second', 'First']);
    expect(tracks.map((track) => track.trackNumber), [1, 2]);
  });
}
