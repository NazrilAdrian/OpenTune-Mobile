import 'model_parsing.dart';

class GenreModel {
  const GenreModel(
      {required this.genreId,
      required this.name,
      this.description,
      required this.createdAt});

  final int genreId;
  final String name;
  final String? description;
  final DateTime createdAt;

  factory GenreModel.fromJson(Map<String, dynamic> json) => GenreModel(
        genreId: requiredInt(json, 'genre_id'),
        name: json['name'] as String,
        description: json['description'] as String?,
        createdAt: requiredTimestamp(json, 'created_at'),
      );
}
