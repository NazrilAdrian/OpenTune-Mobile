import 'package:flutter/material.dart';

import '../../core/services/audio_handler.dart';
import '../../features/song_artist_album/models/song_model.dart';
import '../../features/song_artist_album/repositories/song_repository.dart';
import '../../widgets/opentune_ui.dart';
import '../../widgets/profile_dropdown_button.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const HomeScreen({super.key, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _songs = SongRepository();
  List<SongModel> _uploaded = [];
  List<SongModel> _recommendations = [];
  List<SongModel> _monthly = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final uploaded = await _songs.getLatestSongs(limit: 12);
      final history = await _songs.getRecentlyPlayed(limit: 30);
      final genreId = await _songs.getRecommendedGenreId();
      final recommended = genreId == null
          ? uploaded.take(12).toList()
          : await _songs.getSongsByGenre(genreId,
              excludeIds: history.map((song) => song.songId).toList(),
              limit: 12);
      final now = DateTime.now();
      final localStart = DateTime(now.year, now.month);
      final localEnd = DateTime(now.year, now.month + 1);
      final stats = await _songs.getMostListenedSongIds(localStart, localEnd);
      final byId = {
        for (final song in await _songs
            .getSongsByIds(stats.map((row) => row.songId).toList()))
          song.songId: song
      };
      final monthly =
          stats.map((row) => byId[row.songId]).whereType<SongModel>().toList();
      if (mounted) {
        setState(() {
          _uploaded = uploaded;
          _recommendations =
              recommended.isEmpty ? uploaded.take(12).toList() : recommended;
          _monthly = monthly;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _play(List<SongModel> songs, int index) async {
    try {
      await requestPlaybackNotificationPermission(context);
      await openTuneAudioHandler.playSongs(songs, startIndex: index);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audio gagal diputar: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: OpenTuneColors.background,
        body: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, textAlign: TextAlign.center))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Image.asset('assets/images/logo_opentune.png',
                                    width: 39, height: 39, fit: BoxFit.contain),
                                const SizedBox(width: 9),
                                const Text('OpenTune',
                                    style: TextStyle(
                                        color: OpenTuneColors.purple,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22,
                                        letterSpacing: -0.5)),
                                const Spacer(),
                                const ProfileDropdownButton(
                                    size: 42,
                                    currentScreen: CurrentScreenType.home)
                              ]),
                              const SizedBox(height: 29),
                              const _SectionTitle('Recommendation'),
                              const SizedBox(height: 13),
                              _buildSongList(_recommendations),
                              const SizedBox(height: 27),
                              const _SectionTitle('Just Uploaded'),
                              const SizedBox(height: 13),
                              _buildSongList(_uploaded),
                              const SizedBox(height: 27),
                              const _SectionTitle('Most Listened This Month'),
                              const SizedBox(height: 13),
                              _buildSongList(_monthly),
                            ]),
                      )),
      );

  Widget _buildSongList(List<SongModel> songs) => SizedBox(
      height: 137,
      child: songs.isEmpty
          ? const Align(
              alignment: Alignment.centerLeft,
              child: Text('Belum ada lagu.',
                  style: TextStyle(color: OpenTuneColors.muted, fontSize: 12)))
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: songs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 11),
              itemBuilder: (context, index) {
                final song = songs[index];
                return SizedBox(
                    width: 108,
                    child: InkWell(
                        onTap: () => _play(songs, index),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SongCover(
                                  coverImage: song.coverPath ??
                                      song.albumCoverPath ??
                                      '',
                                  width: 108,
                                  height: 88,
                                  radius: 5),
                              const SizedBox(height: 7),
                              Text(song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: OpenTuneColors.text,
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text(song.artistName ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: OpenTuneColors.muted,
                                      fontSize: 10,
                                      fontFamily: 'Poppins')),
                            ])));
              }));
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(
          color: OpenTuneColors.text,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 19,
          letterSpacing: -0.3));
}
