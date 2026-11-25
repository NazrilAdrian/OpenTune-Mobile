import '../../../core/network/supabase_config.dart';
import '../models/genre_model.dart';

class GenreRepository {
  Future<List<GenreModel>> getGenres() async {
    final rows = await SupabaseConfig.client
        .from('genres')
        .select()
        .order('name', ascending: true);
    return rows
        .map((row) => GenreModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }
}
