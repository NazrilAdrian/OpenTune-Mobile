import '../../../core/network/supabase_config.dart';
import '../models/album_model.dart';
import '../models/song_model.dart';
import 'repository_guard.dart';

class AlbumRepository {
  static const _table = 'albums';
  static const _selection = '*, artists(name)';

  Future<List<AlbumModel>> getOwnedAlbums(String userId) async {
    requireUserId(userId);
    final rows = await SupabaseConfig.client
        .from(_table)
        .select(_selection)
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .order('album_id', ascending: true);
    return _albums(rows);
  }

  Future<List<AlbumModel>> searchAlbums(String query) async {
    final term = query.trim();
    if (term.isEmpty) return [];
    final client = SupabaseConfig.client;
    final artistRows = await client
        .from('artists')
        .select('artist_id')
        .ilike('name', '%$term%');
    final byName = await client
        .from(_table)
        .select(_selection)
        .ilike('name', '%${escapeIlike(term)}%')
        .order('created_at', ascending: false)
        .order('album_id', ascending: true);
    final byArtist = artistRows.isEmpty
        ? <dynamic>[]
        : await client
            .from(_table)
            .select(_selection)
            .inFilter(
                'artist_id', artistRows.map((row) => row['artist_id']).toList())
            .order('created_at', ascending: false)
            .order('album_id', ascending: true);
    final rowsById = <int, Map<String, dynamic>>{};
    for (final row in [...byName, ...byArtist]) {
      rowsById[(row['album_id'] as num).toInt()] =
          Map<String, dynamic>.from(row);
    }
    final rows = rowsById.values.toList()
      ..sort((a, b) {
        final byDate = DateTime.parse(b['created_at'] as String)
            .compareTo(DateTime.parse(a['created_at'] as String));
        return byDate != 0
            ? byDate
            : (a['album_id'] as num).compareTo(b['album_id'] as num);
      });
    return _albums(rows);
  }

  Future<AlbumModel> createAlbum(Map<String, dynamic> data) async {
    final userId = requireUserId();
    final row = await SupabaseConfig.client
        .from(_table)
        .insert({...data, 'user_id': userId})
        .select(_selection)
        .single();
    return AlbumModel.fromJson(row);
  }

  Future<void> updateAlbum(
      int albumId, String userId, Map<String, dynamic> data) async {
    requireUserId(userId);
    final changes = allowedChanges(
        data,
        {
          'artist_id',
          'name',
          'cover_path',
          'release_date',
        },
        'album');
    final changed = await SupabaseConfig.client
        .from(_table)
        .update(changes)
        .eq('album_id', albumId)
        .eq('user_id', userId)
        .select('album_id')
        .maybeSingle();
    if (changed == null) {
      throw StateError(
          'Album tidak ditemukan atau bukan milik pengguna aktif.');
    }
  }

  Future<({AlbumModel album, List<SongModel> songs})?> getAlbumWithSongs(
      int albumId) async {
    final row = await SupabaseConfig.client
        .from(_table)
        .select(_selection)
        .eq('album_id', albumId)
        .maybeSingle();
    if (row == null) return null;
    final songs = await SupabaseConfig.client
        .from('songs')
        .select('*, artists(name), albums(name, cover_path), genres(name)')
        .eq('album_id', albumId)
        .order('track_number', ascending: true)
        .order('song_id', ascending: true);
    return (
      album: AlbumModel.fromJson(row),
      songs: songs
          .map((song) => SongModel.fromJson(Map<String, dynamic>.from(song)))
          .toList(),
    );
  }

  Future<void> deleteAlbum(int albumId, String userId) async {
    requireUserId(userId);
    final deleted = await SupabaseConfig.client
        .from(_table)
        .delete()
        .eq('album_id', albumId)
        .eq('user_id', userId)
        .select('album_id')
        .maybeSingle();
    if (deleted == null) {
      throw StateError(
          'Album tidak ditemukan atau bukan milik pengguna aktif.');
    }
  }
}

List<AlbumModel> _albums(List<dynamic> rows) => rows
    .map((row) => AlbumModel.fromJson(Map<String, dynamic>.from(row)))
    .toList();
