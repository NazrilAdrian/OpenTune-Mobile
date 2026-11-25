import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/services/audio_handler.dart';
import '../../widgets/opentune_ui.dart';

class FullScreenPlayerScreen extends StatefulWidget {
  const FullScreenPlayerScreen({super.key});

  @override
  State<FullScreenPlayerScreen> createState() => _FullScreenPlayerScreenState();
}

class _FullScreenPlayerScreenState extends State<FullScreenPlayerScreen> {
  bool _isLiked = false;

  Future<void> _showQueue() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
          child: ListView(
        shrinkWrap: true,
        children: openTuneAudioHandler.queue.value
            .asMap()
            .entries
            .map((entry) => ListTile(
                  title: Text(entry.value.title),
                  subtitle: Text(entry.value.artist ?? ''),
                  onTap: () {
                    Navigator.pop(context);
                    openTuneAudioHandler.skipToQueueItem(entry.key);
                  },
                ))
            .toList(),
      )),
    );
  }

  String _formatTime(Duration duration) {
    final int totalSeconds = duration.inSeconds;
    final int minutes = totalSeconds ~/ 60;
    final int remainingSeconds = totalSeconds % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Poppins',
            ),
        primaryTextTheme: Theme.of(context).primaryTextTheme.apply(
              fontFamily: 'Poppins',
            ),
      ),
      child: Scaffold(
        backgroundColor: OpenTuneColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Top navbar
              SizedBox(
                height: 58,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 30,
                        ),
                        color: OpenTuneColors.text,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 42,
                          minHeight: 42,
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'NOW PLAYING',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: OpenTuneColors.text,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'OpenTune',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: OpenTuneColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _showQueue,
                        icon: const Icon(
                          Icons.queue_music_rounded,
                          size: 25,
                        ),
                        color: OpenTuneColors.text,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 42,
                          minHeight: 42,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Area cover di tengah, kontrol di bagian bawah.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double coverSize = math
                        .min(
                          constraints.maxWidth - 48,
                          constraints.maxHeight - 220,
                        )
                        .clamp(160.0, 310.0)
                        .toDouble();

                    return Column(
                      children: [
                        // Cover berada di tengah ruang yang tersedia.
                        Expanded(
                          child: Center(
                            child: StreamBuilder<MediaItem?>(
                              stream: openTuneAudioHandler.mediaItem,
                              builder: (context, snapshot) => SongCover(
                                coverImage: snapshot.data?.artUri?.toString() ??
                                    'assets/images/covers/setsunarensa_cover.jpg',
                                width: coverSize,
                                height: coverSize,
                                radius: 14,
                              ),
                            ),
                          ),
                        ),

                        // Semua kontrol dikelompokkan di bawah.
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            26,
                            8,
                            26,
                            140,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Judul lagu dan tombol favorit.
                              Row(
                                children: [
                                  Expanded(
                                    child: StreamBuilder<MediaItem?>(
                                      stream: openTuneAudioHandler.mediaItem,
                                      builder: (context, snapshot) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot.data?.title ??
                                                'Pilih lagu',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: OpenTuneColors.text,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            snapshot.data?.artist ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: OpenTuneColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLiked = !_isLiked;
                                      });
                                    },
                                    icon: Icon(
                                      _isLiked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 25,
                                      color: _isLiked
                                          ? OpenTuneColors.purple
                                          : OpenTuneColors.muted,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Progress lagu.
                              StreamBuilder<Duration>(
                                stream:
                                    openTuneAudioHandler.player.positionStream,
                                builder: (context, positionSnapshot) {
                                  return StreamBuilder<Duration?>(
                                    stream: openTuneAudioHandler
                                        .player.durationStream,
                                    builder: (context, durationSnapshot) {
                                      final duration = durationSnapshot.data ??
                                          Duration.zero;
                                      final position = positionSnapshot.data ??
                                          Duration.zero;
                                      final safeProgress =
                                          duration.inMilliseconds == 0
                                              ? 0.0
                                              : (position.inMilliseconds /
                                                      duration.inMilliseconds)
                                                  .clamp(0.0, 1.0);

                                      return Column(
                                        children: [
                                          SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                              trackHeight: 3,
                                              thumbShape:
                                                  const RoundSliderThumbShape(
                                                enabledThumbRadius: 5,
                                              ),
                                              overlayShape:
                                                  const RoundSliderOverlayShape(
                                                overlayRadius: 12,
                                              ),
                                              activeTrackColor:
                                                  OpenTuneColors.purple,
                                              inactiveTrackColor:
                                                  const Color(0xFFE6E6EB),
                                              thumbColor: OpenTuneColors.purple,
                                            ),
                                            child: Slider(
                                              value: safeProgress,
                                              onChanged: duration ==
                                                      Duration.zero
                                                  ? null
                                                  : (value) => openTuneAudioHandler
                                                      .seek(Duration(
                                                          milliseconds:
                                                              (duration.inMilliseconds *
                                                                      value)
                                                                  .round())),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  _formatTime(position),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w400,
                                                    color: OpenTuneColors.muted,
                                                  ),
                                                ),
                                                Text(
                                                  _formatTime(duration),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w400,
                                                    color: OpenTuneColors.muted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 10),

                              // Tombol kontrol pemutar.
                              StreamBuilder<PlaybackState>(
                                stream: openTuneAudioHandler.playbackState,
                                builder: (context, snapshot) {
                                  final isPlaying =
                                      snapshot.data?.playing ?? false;
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: () => openTuneAudioHandler
                                            .setShuffleMode(openTuneAudioHandler
                                                    .player.shuffleModeEnabled
                                                ? AudioServiceShuffleMode.none
                                                : AudioServiceShuffleMode.all),
                                        icon: Icon(Icons.shuffle_rounded,
                                            color: openTuneAudioHandler
                                                    .player.shuffleModeEnabled
                                                ? OpenTuneColors.purple
                                                : OpenTuneColors.muted),
                                        iconSize: 21,
                                        color: OpenTuneColors.muted,
                                      ),
                                      IconButton(
                                        onPressed:
                                            openTuneAudioHandler.skipToPrevious,
                                        icon: const Icon(
                                          Icons.skip_previous_rounded,
                                        ),
                                        iconSize: 34,
                                        color: OpenTuneColors.text,
                                      ),
                                      GestureDetector(
                                        onTap: () => isPlaying
                                            ? openTuneAudioHandler.pause()
                                            : openTuneAudioHandler.play(),
                                        child: Container(
                                          width: 62,
                                          height: 62,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                OpenTuneColors.purpleLight,
                                                OpenTuneColors.purple,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: OpenTuneColors.purple
                                                    .withValues(alpha: 0.22),
                                                blurRadius: 16,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            isPlaying
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            size: 36,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed:
                                            openTuneAudioHandler.skipToNext,
                                        icon: const Icon(
                                          Icons.skip_next_rounded,
                                        ),
                                        iconSize: 34,
                                        color: OpenTuneColors.text,
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            openTuneAudioHandler.setRepeatMode(
                                                switch (openTuneAudioHandler
                                                    .player.loopMode) {
                                          LoopMode.off =>
                                            AudioServiceRepeatMode.all,
                                          LoopMode.all =>
                                            AudioServiceRepeatMode.one,
                                          _ => AudioServiceRepeatMode.none
                                        }),
                                        icon: Icon(Icons.repeat_rounded,
                                            color: openTuneAudioHandler
                                                        .player.loopMode ==
                                                    LoopMode.off
                                                ? OpenTuneColors.muted
                                                : OpenTuneColors.purple),
                                        iconSize: 21,
                                        color: OpenTuneColors.muted,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
