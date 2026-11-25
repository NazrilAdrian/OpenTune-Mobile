import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../features/song_artist_album/models/album_model.dart';
import '../../features/song_artist_album/models/song_model.dart';
import '../../features/song_artist_album/repositories/album_repository.dart';
import '../../features/song_artist_album/repositories/artist_repository.dart';
import '../../features/song_artist_album/repositories/repository_guard.dart';
import '../../features/song_artist_album/repositories/song_repository.dart';
import '../../widgets/opentune_ui.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final _songs = SongRepository();
  final _albums = AlbumRepository();
  final _artists = ArtistRepository();
  final _storage = StorageService();
  int _selectedTab = 0;
  bool _loading = true;
  String? _error;
  List<SongModel> _songRows = [];
  List<AlbumModel> _albumRows = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = requireUserId();
      final songs = await _songs.getOwnedSongs(uid);
      final albums = await _albums.getOwnedAlbums(uid);
      if (mounted) {
        setState(() {
          _songRows = songs;
          _albumRows = albums;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editSong(SongModel song) async {
    final title = TextEditingController(text: song.title);
    final artist = TextEditingController(text: song.artistName ?? '');
    final form = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Edit song'),
              content: Form(
                  key: form,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(
                        controller: title,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Wajib diisi'
                            : null),
                    TextFormField(
                        controller: artist,
                        decoration: const InputDecoration(labelText: 'Artist'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Wajib diisi'
                            : null),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      if (form.currentState!.validate()) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text('Save'))
              ],
            ));
    if (saved != true) return;
    try {
      final artistRow = await _artists.findOrCreateArtist(artist.text);
      await _songs.updateSong(song.songId, requireUserId(),
          {'title': title.text.trim(), 'artist_id': artistRow.artistId});
      await _refresh();
    } catch (error) {
      _message('Song gagal diperbarui: $error');
    }
  }

  Future<void> _editAlbum(AlbumModel album) async {
    final name = TextEditingController(text: album.name);
    final artist = TextEditingController(text: album.artistName ?? '');
    final form = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Edit album'),
              content: Form(
                  key: form,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(
                        controller: name,
                        decoration:
                            const InputDecoration(labelText: 'Album name'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Wajib diisi'
                            : null),
                    TextFormField(
                        controller: artist,
                        decoration: const InputDecoration(labelText: 'Artist'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Wajib diisi'
                            : null),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      if (form.currentState!.validate()) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text('Save'))
              ],
            ));
    if (saved != true) return;
    try {
      final artistRow = await _artists.findOrCreateArtist(artist.text);
      await _albums.updateAlbum(album.albumId, requireUserId(),
          {'name': name.text.trim(), 'artist_id': artistRow.artistId});
      await _refresh();
    } catch (error) {
      _message('Album gagal diperbarui: $error');
    }
  }

  Future<bool> _confirm(String title) async =>
      await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Konfirmasi hapus'),
                content: Text('Hapus "$title"?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete')),
                ],
              )) ??
      false;

  Future<void> _deleteSong(SongModel song) async {
    if (!await _confirm(song.title)) return;
    try {
      await _songs.deleteSong(song.songId, requireUserId());
      try {
        await _storage.removeObjects(StorageBucket.audioFiles, [song.filePath]);
        if (song.coverPath != null && song.coverPath != song.albumCoverPath) {
          await _storage.removeObjects(StorageBucket.covers, [song.coverPath!]);
        }
      } catch (error) {
        _message(
            'Lagu terhapus dari katalog, tetapi file perlu cleanup manual: $error');
      }
      await _refresh();
    } catch (error) {
      _message('Song gagal dihapus: $error');
    }
  }

  Future<void> _deleteAlbum(AlbumModel album) async {
    if (!await _confirm(album.name)) return;
    try {
      final owner = requireUserId();
      final owned = await _albums.getOwnedAlbumsWithSongs(owner);
      final matches =
          owned.where((item) => item.album.albumId == album.albumId).toList();
      if (matches.isEmpty) throw StateError('Album bukan milik akun aktif.');
      final files = <String>{
        album.coverPath ?? '',
        ...matches.single.songs.map((song) => song.filePath),
        ...matches.single.songs
            .where((song) => song.coverPath != null)
            .map((song) => song.coverPath!)
      }..remove('');
      await _albums.deleteAlbum(album.albumId, owner);
      try {
        await _storage.removeObjects(StorageBucket.audioFiles,
            matches.single.songs.map((song) => song.filePath).toSet().toList());
        await _storage.removeObjects(
            StorageBucket.covers,
            files
                .where((path) =>
                    path == album.coverPath ||
                    matches.single.songs.any((song) => song.coverPath == path))
                .toSet()
                .toList());
      } catch (error) {
        _message(
            'Album dan lagu terhapus dari katalog, tetapi file Storage perlu cleanup manual: $error');
      }
      await _refresh();
    } catch (error) {
      _message('Album gagal dihapus: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _selectedTab == 0 ? _songRows : _albumRows;
    return Scaffold(
      backgroundColor: OpenTuneColors.background,
      body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Manage',
                  style: TextStyle(
                      color: OpenTuneColors.text,
                      fontSize: 26,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('Manage your uploaded songs and albums.',
                  style: TextStyle(color: OpenTuneColors.muted, fontSize: 12)),
              const SizedBox(height: 21),
              Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEDEDF2),
                      borderRadius: BorderRadius.circular(9)),
                  child: Row(children: [
                    _tabButton('Song (${_songRows.length})', 0),
                    _tabButton('Album (${_albumRows.length})', 1),
                  ])),
            ])),
        Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, textAlign: TextAlign.center))
                    : items.isEmpty
                        ? const Center(child: Text('Belum ada data.'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 11),
                            itemBuilder: (context, index) {
                              final song =
                                  _selectedTab == 0 ? _songRows[index] : null;
                              final album =
                                  _selectedTab == 1 ? _albumRows[index] : null;
                              final title = song?.title ?? album!.name;
                              final artist =
                                  song?.artistName ?? album?.artistName ?? '';
                              final cover = song?.coverPath ??
                                  song?.albumCoverPath ??
                                  album?.coverPath ??
                                  '';
                              return OpenTunePanel(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(children: [
                                    SongCover(
                                        coverImage: cover,
                                        width: 58,
                                        height: 58,
                                        radius: 6,
                                        fallbackIcon: _selectedTab == 0
                                            ? Icons.music_note_rounded
                                            : Icons.album_rounded),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: OpenTuneColors.text,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 4),
                                          Text(artist,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: OpenTuneColors.muted,
                                                  fontSize: 11)),
                                          const SizedBox(height: 7),
                                          Text(
                                              _selectedTab == 0
                                                  ? 'Uploaded song'
                                                  : 'Uploaded album',
                                              style: const TextStyle(
                                                  color: OpenTuneColors.purple,
                                                  fontSize: 10))
                                        ])),
                                    IconButton(
                                        tooltip: 'Edit',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => song != null
                                            ? _editSong(song)
                                            : _editAlbum(album!),
                                        icon: const Icon(Icons.edit_outlined,
                                            color: OpenTuneColors.muted,
                                            size: 20)),
                                    IconButton(
                                        tooltip: 'Delete',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => song != null
                                            ? _deleteSong(song)
                                            : _deleteAlbum(album!),
                                        icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Color(0xFFD95365),
                                            size: 21)),
                                  ]));
                            },
                          )),
      ])),
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
        child: InkWell(
            onTap: () => setState(() => _selectedTab = index),
            borderRadius: BorderRadius.circular(7),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4)
                        ]
                      : null),
              child: Center(
                  child: Text(label,
                      style: TextStyle(
                          color: selected
                              ? OpenTuneColors.purple
                              : OpenTuneColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700))),
            )));
  }
}
