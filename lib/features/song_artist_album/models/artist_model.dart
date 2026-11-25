import 'model_parsing.dart';

class ArtistModel {
  const ArtistModel({
    required this.artistId,
    required this.name,
    this.bio,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  final int artistId;
  final String name;
  final String? bio, image;
  final DateTime? createdAt, updatedAt;

  factory ArtistModel.fromJson(Map<String, dynamic> json) => ArtistModel(
        artistId: requiredInt(json, 'artist_id'),
        name: json['name'] as String,
        bio: json['bio'] as String?,
        image: json['image'] as String?,
        createdAt: requiredTimestamp(json, 'created_at'),
        updatedAt: requiredTimestamp(json, 'updated_at'),
      );
}
