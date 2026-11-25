import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/audio_handler.dart';
import '../../features/song_artist_album/models/album_model.dart';
import '../../features/song_artist_album/models/song_model.dart';
import '../../features/song_artist_album/repositories/album_repository.dart';
import '../../features/song_artist_album/repositories/song_repository.dart';
import '../../widgets/opentune_ui.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _songRepository = SongRepository();
  final _albumRepository = AlbumRepository();
  Timer? _debounce;
  List<SongModel> _recent = [], _songs = [];
  List<AlbumModel> _albums = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    try {
      final rows = await _songRepository.getRecentlyPlayed();
      if (mounted) setState(() => _recent = rows);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  void _onQuery(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _songs = [];
        _albums = [];
        _error = null;
        _loading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _songRepository.searchSongs(query),
        _albumRepository.searchAlbums(query)
      ]);
      if (mounted) {
        setState(() {
          _songs = results[0] as List<SongModel>;
          _albums = results[1] as List<AlbumModel>;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _play(SongModel song) async {
    try {
      await requestPlaybackNotificationPermission(context);
      await openTuneAudioHandler.playSong(song);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audio gagal diputar: $error')));
      }
    }
  }

  Future<void> _removeFromHistory(SongModel song) async {
    try {
      await _songRepository.deletePlayHistory(song.songId);
      await _loadRecent();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Riwayat gagal dihapus: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searching = _controller.text.trim().isNotEmpty;
    return Theme(
        data: Theme.of(context).copyWith(
            textTheme:
                Theme.of(context).textTheme.apply(fontFamily: 'Poppins')),
        child: Scaffold(
          backgroundColor: OpenTuneColors.background,
          body: SafeArea(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
                  children: [
                const Text('Search',
                    style: TextStyle(
                        color: OpenTuneColors.text,
                        fontSize: 26,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 7),
                const Text('Find your favorite songs and albums.',
                    style: TextStyle(
                        color: OpenTuneColors.muted,
                        fontSize: 12,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 21),
                TextField(
                    controller: _controller,
                    onChanged: _onQuery,
                    showCursor: true,
                    enableInteractiveSelection: true,
                    style: const TextStyle(
                        color: OpenTuneColors.text,
                        fontSize: 14,
                        fontFamily: 'Poppins'),
                    cursorColor: OpenTuneColors.purple,
                    decoration: InputDecoration(
                        hintText: 'Search song or album...',
                        hintStyle: const TextStyle(
                            color: OpenTuneColors.muted,
                            fontSize: 13,
                            fontFamily: 'Poppins'),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: OpenTuneColors.purple),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide:
                                const BorderSide(color: OpenTuneColors.border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide:
                                const BorderSide(color: OpenTuneColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(
                                color: OpenTuneColors.purple, width: 1.3)))),
                const SizedBox(height: 28),
                if (searching) ...[
                  const Text('Search Results',
                      style: TextStyle(
                          color: OpenTuneColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  if (_loading)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator()))
                  else if (_error != null)
                    Text(_error!,
                        style: const TextStyle(color: OpenTuneColors.muted))
                  else if (_songs.isEmpty && _albums.isEmpty)
                    const Text('Tidak ada hasil.',
                        style: TextStyle(color: OpenTuneColors.muted))
                  else ...[
                    ..._songs.map((song) => _ResultRow(
                        title: song.title,
                        subtitle: song.artistName ?? '',
                        cover: song.coverPath ?? song.albumCoverPath ?? '',
                        onTap: () => _play(song))),
                    ..._albums.map((album) => _ResultRow(
                        title: album.name,
                        subtitle: album.artistName ?? '',
                        cover: album.coverPath ?? '',
                        album: true)),
                  ],
                ] else ...[
                  const Text('Recently Played',
                      style: TextStyle(
                          color: OpenTuneColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  if (_recent.isEmpty)
                    const Text('Belum ada lagu yang diputar.',
                        style: TextStyle(color: OpenTuneColors.muted))
                  else
                    ..._recent.map((song) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ResultRow(
                            title: song.title,
                            subtitle: song.artistName ?? '',
                            cover: song.coverPath ?? song.albumCoverPath ?? '',
                            onTap: () => _play(song),
                            onDelete: () => _removeFromHistory(song)))),
                ],
              ])),
        ));
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(
      {required this.title,
      required this.subtitle,
      required this.cover,
      this.onTap,
      this.onDelete,
      this.album = false});
  final String title, subtitle, cover;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool album;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: OpenTuneColors.border, width: .8)),
              child: Row(children: [
                SongCover(
                    coverImage: cover,
                    width: 50,
                    height: 50,
                    radius: 8,
                    fallbackIcon:
                        album ? Icons.album_rounded : Icons.music_note_rounded),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: OpenTuneColors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: OpenTuneColors.muted, fontSize: 11))
                    ])),
                if (onDelete != null)
                  IconButton(
                    tooltip: 'Remove from history',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: OpenTuneColors.muted, size: 20),
                  )
                else if (!album)
                  const Icon(Icons.play_arrow_rounded,
                      color: OpenTuneColors.purple),
              ]))));
}
