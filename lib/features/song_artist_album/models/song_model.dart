import 'model_parsing.dart';

class SongModel {
  const SongModel({
    required this.songId,
    required this.userId,
    required this.title,
    required this.filePath,
    required this.artistId,
    this.albumId,
    this.genreId,
    this.trackNumber,
    this.coverPath,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
    this.artistName,
    this.albumName,
    this.albumCoverPath,
    this.genreName,
  });

  final int songId;
  final String userId;
  final String title;
  final String filePath;
  final int artistId, duration;
  final int? albumId, genreId, trackNumber;
  final String? coverPath, artistName, albumName, albumCoverPath, genreName;
  final DateTime createdAt, updatedAt;

  factory SongModel.fromJson(Map<String, dynamic> json) => SongModel(
        songId: requiredInt(json, 'song_id'),
        userId: json['user_id'] as String,
        title: json['title'] as String,
        filePath: json['file_path'] as String,
        artistId: requiredInt(json, 'artist_id'),
        albumId:
            json['album_id'] == null ? null : requiredInt(json, 'album_id'),
        genreId:
            json['genre_id'] == null ? null : requiredInt(json, 'genre_id'),
        trackNumber: json['track_number'] == null
            ? null
            : requiredInt(json, 'track_number'),
        coverPath: json['cover_path'] as String?,
        duration: requiredInt(json, 'duration'),
        createdAt: requiredTimestamp(json, 'created_at'),
        updatedAt: requiredTimestamp(json, 'updated_at'),
        artistName: _relation(json['artists'])?['name'] as String?,
        albumName: _relation(json['albums'])?['name'] as String?,
        albumCoverPath: _relation(json['albums'])?['cover_path'] as String?,
        genreName: _relation(json['genres'])?['name'] as String?,
      );
}

Map<String, dynamic>? _relation(dynamic value) => value is Map<String, dynamic>
    ? value
    : value is List && value.isNotEmpty && value.first is Map<String, dynamic>
        ? value.first as Map<String, dynamic>
        : null;
