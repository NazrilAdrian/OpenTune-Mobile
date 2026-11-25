import 'model_parsing.dart';

class AlbumModel {
  const AlbumModel({
    required this.albumId,
    required this.userId,
    required this.name,
    required this.artistId,
    this.coverPath,
    this.releaseDate,
    required this.createdAt,
    required this.updatedAt,
    this.artistName,
  });

  final int albumId;
  final String userId, name;
  final int artistId;
  final String? coverPath, artistName;
  final DateTime? releaseDate;
  final DateTime createdAt, updatedAt;

  factory AlbumModel.fromJson(Map<String, dynamic> json) => AlbumModel(
        albumId: requiredInt(json, 'album_id'),
        userId: json['user_id'] as String,
        name: json['name'] as String,
        artistId: requiredInt(json, 'artist_id'),
        coverPath: json['cover_path'] as String?,
        releaseDate: optionalDate(json, 'release_date'),
        createdAt: requiredTimestamp(json, 'created_at'),
        updatedAt: requiredTimestamp(json, 'updated_at'),
        artistName: _albumArtist(json['artists'])?['name'] as String?,
      );
}

Map<String, dynamic>? _albumArtist(dynamic value) => value
        is Map<String, dynamic>
    ? value
    : value is List && value.isNotEmpty && value.first is Map<String, dynamic>
        ? value.first as Map<String, dynamic>
        : null;
