import '../../../core/network/supabase_config.dart';
import '../models/song_model.dart';
import 'repository_guard.dart';

class SongRepository {
  static const _table = 'songs';
  static const _selection =
      '*, artists(name), albums(name, cover_path), genres(name)';

  Future<List<SongModel>> getLatestSongs({int limit = 20}) async {
    final rows = await SupabaseConfig.client
        .from(_table)
        .select(_selection)
        .order('created_at', ascending: false)
        .order('song_id', ascending: true)
        .limit(limit);
    return _songs(rows);
  }

  Future<List<SongModel>> getOwnedSongs(String userId) async {
    requireUserId(userId);
    final rows = await SupabaseConfig.client
        .from(_table)
        .select(_selection)
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .order('song_id', ascending: true);
    return _songs(rows);
  }

  Future<List<SongModel>> searchSongs(String query) async {
    final term = query.trim();
    if (term.isEmpty) return [];
    final client = SupabaseConfig.client;
    final artistRows = await client
        .from('artists')
        .select('artist_id')
        .ilike('name', '%${escapeIlike(term)}%');
    final byTitle = await client
        .from(_table)
        .select(_selection)
        .ilike('title', '%${escapeIlike(term)}%')
        .order('created_at', ascending: false)
        .order('song_id', ascending: true);
    final byArtist = artistRows.isEmpty
        ? <dynamic>[]
        : await client
            .from(_table)
            .select(_selection)
            .inFilter(
                'artist_id', artistRows.map((row) => row['artist_id']).toList())
            .order('created_at', ascending: false)
            .order('song_id', ascending: true);
    final rowsById = <int, Map<String, dynamic>>{};
    for (final row in [...byTitle, ...byArtist]) {
      rowsById[(row['song_id'] as num).toInt()] =
          Map<String, dynamic>.from(row);
    }
    final rows = rowsById.values.toList()
      ..sort((a, b) {
        final byDate = DateTime.parse(b['created_at'] as String)
            .compareTo(DateTime.parse(a['created_at'] as String));
        return byDate != 0
            ? byDate
            : (a['song_id'] as num).compareTo(b['song_id'] as num);
      });
    return _songs(rows);
  }

  Future<List<SongModel>> getSongsByAlbum(int albumId) async {
    final rows = await SupabaseConfig.client
        .from(_table)
        .select(_selection)
        .eq('album_id', albumId)
        .order('track_number', ascending: true)
        .order('song_id', ascending: true);
    return _songs(rows);
  }

  Future<SongModel> createSong(Map<String, dynamic> data) async {
    final userId = requireUserId();
    final row = await SupabaseConfig.client
        .from(_table)
        .insert({...data, 'user_id': userId})
        .select(_selection)
        .single();
    return SongModel.fromJson(row);
  }

  Future<void> updateSong(
      int songId, String userId, Map<String, dynamic> data) async {
    requireUserId(userId);
    final changes = allowedChanges(
        data,
        {
          'artist_id',
          'album_id',
          'genre_id',
          'track_number',
          'title',
          'file_path',
          'cover_path',
          'duration',
        },
        'lagu');
    final changed = await SupabaseConfig.client
        .from(_table)
        .update(changes)
        .eq('song_id', songId)
        .eq('user_id', userId)
        .select('song_id')
        .maybeSingle();
    if (changed == null) {
      throw StateError('Lagu tidak ditemukan atau bukan milik pengguna aktif.');
    }
  }

  Future<void> deleteSong(int songId, String userId) async {
    requireUserId(userId);
    final deleted = await SupabaseConfig.client
        .from(_table)
        .delete()
        .eq('song_id', songId)
        .eq('user_id', userId)
        .select('song_id')
        .maybeSingle();
    if (deleted == null) {
      throw StateError('Lagu tidak ditemukan atau bukan milik pengguna aktif.');
    }
  }

  Future<List<SongModel>> getSongsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final rows = await SupabaseConfig.client
        .from(_table)
        .select(_selection)
        .inFilter('song_id', ids)
        .order('song_id', ascending: true);
    return _songs(rows);
  }
}

List<SongModel> _songs(List<dynamic> rows) => rows
    .map((row) => SongModel.fromJson(Map<String, dynamic>.from(row)))
    .toList();
