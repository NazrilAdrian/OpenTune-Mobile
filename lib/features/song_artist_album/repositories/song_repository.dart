import '../models/song_model.dart';
import 'repository_guard.dart';
import '../../../core/network/supabase_config.dart';

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
        .ilike('name', '%${escapeIlike(term)}%')
        .limit(100);
    final byTitle = await client
        .from(_table)
        .select(_selection)
        .ilike('title', '%${escapeIlike(term)}%')
        .order('created_at', ascending: false)
        .order('song_id', ascending: true)
        .limit(30);
    final byArtist = artistRows.isEmpty
        ? <dynamic>[]
        : await client
            .from(_table)
            .select(_selection)
            .inFilter(
                'artist_id', artistRows.map((row) => row['artist_id']).toList())
            .order('created_at', ascending: false)
            .order('song_id', ascending: true)
            .limit(30);
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
    return _songs(rows.take(30).toList());
  }

  Future<List<SongModel>> getSongsByGenre(int genreId,
      {List<int> excludeIds = const [], int limit = 20}) async {
    final rows = await SupabaseConfig.client
        .from(_table)
        .select(_selection)
        .eq('genre_id', genreId)
        .order('created_at', ascending: false)
        .limit(limit + excludeIds.length);
    return _songs(rows
        .where((row) => !excludeIds.contains((row['song_id'] as num).toInt()))
        .take(limit)
        .toList());
  }

  Future<List<SongModel>> getRecentlyPlayed({int limit = 20}) async {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await SupabaseConfig.client
        .from('song_plays')
        .select('played_at, songs!inner($_selection)')
        .eq('user_id', userId)
        .order('played_at', ascending: false)
        .limit(limit * 5);
    final seen = <int>{};
    final songs = <SongModel>[];
    for (final row in rows) {
      final songRow = row['songs'];
      final value =
          songRow is List ? (songRow.isEmpty ? null : songRow.first) : songRow;
      if (value is! Map) continue;
      final song = SongModel.fromJson(Map<String, dynamic>.from(value));
      if (seen.add(song.songId)) songs.add(song);
      if (songs.length == limit) break;
    }
    return songs;
  }

  Future<int?> getRecommendedGenreId({int historyLimit = 30}) async {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) return null;
    final rows = await SupabaseConfig.client
        .from('song_plays')
        .select('songs!inner(genre_id)')
        .eq('user_id', userId)
        .order('played_at', ascending: false)
        .limit(historyLimit);
    final counts = <int, int>{};
    for (final row in rows) {
      final songs = row['songs'];
      final song = songs is List ? (songs.isEmpty ? null : songs.first) : songs;
      final id = song is Map ? song['genre_id'] : null;
      if (id is num)
        counts.update(id.toInt(), (count) => count + 1, ifAbsent: () => 1);
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Future<List<({int songId, int playCount})>> getMostListenedSongIds(
      DateTime start, DateTime end,
      {int limit = 20}) async {
    final rows =
        await SupabaseConfig.client.rpc('get_most_listened_song_ids', params: {
      'p_start': start.toUtc().toIso8601String(),
      'p_end': end.toUtc().toIso8601String(),
      'p_limit': limit,
    });
    return (rows as List)
        .map((row) => (
              songId: (row['song_id'] as num).toInt(),
              playCount: (row['play_count'] as num).toInt(),
            ))
        .toList();
  }

  Future<void> recordPlay(int songId) async {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) return;
    await SupabaseConfig.client.from('song_plays').insert({
      'song_id': songId,
      'user_id': userId,
    });
  }

  Future<void> deletePlayHistory(int songId) async {
    final userId = requireUserId();
    await SupabaseConfig.client
        .from('song_plays')
        .delete()
        .eq('user_id', userId)
        .eq('song_id', songId);
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

  Future<int> nextTrackNumber(int albumId, String userId) async {
    requireUserId(userId);
    final rows = await SupabaseConfig.client
        .from(_table)
        .select('track_number')
        .eq('album_id', albumId)
        .eq('user_id', userId);
    var next = 1;
    for (final row in rows) {
      final value = row['track_number'];
      if (value is num && value.toInt() >= next) next = value.toInt() + 1;
    }
    return next;
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

  Future<void> createSongs(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) throw ArgumentError('Minimal satu lagu harus disimpan.');
    final userId = requireUserId();
    await SupabaseConfig.client
        .from(_table)
        .insert(data.map((song) => {...song, 'user_id': userId}).toList());
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
