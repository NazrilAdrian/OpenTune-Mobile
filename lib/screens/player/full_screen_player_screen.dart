import 'package:flutter/material.dart';

import '../../widgets/opentune_ui.dart';
import '../../widgets/player_state.dart';
import '../review/review_screen.dart';

class FullScreenPlayerScreen extends StatefulWidget {
  const FullScreenPlayerScreen({super.key});

  @override
  State<FullScreenPlayerScreen> createState() => _FullScreenPlayerScreenState();
}

class _FullScreenPlayerScreenState extends State<FullScreenPlayerScreen> {
  bool _isLiked = false;
  double _volume = 0.7;

  static const double _duration = 222;

  String _formatTime(double seconds) {
    final value = seconds.round();
    final minutes = value ~/ 60;
    final remainingSeconds = value % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final artworkSize =
        (MediaQuery.of(context).size.width - 76).clamp(220.0, 320.0).toDouble();

    return Scaffold(
      backgroundColor: OpenTuneColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header player
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Minimalkan player',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 29,
                      color: OpenTuneColors.text,
                    ),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Text(
                          'NOW PLAYING',
                          style: TextStyle(
                            color: OpenTuneColors.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'OpenTune',
                          style: TextStyle(
                            color: OpenTuneColors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Queue (tampilan saja)',
                    onPressed: () {},
                    icon: const Icon(
                      Icons.queue_music_rounded,
                      color: OpenTuneColors.text,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Album cover
                    SongCover(
                      seed: 'setsunarensa',
                      width: artworkSize,
                      height: artworkSize,
                      radius: 12,
                    ),
                    const SizedBox(height: 26),

                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Setsunarensa',
                                style: TextStyle(
                                  color: OpenTuneColors.text,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Radwimps',
                                style: TextStyle(
                                  color: OpenTuneColors.muted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        //Tombol Review & Rating
                        IconButton(
                          tooltip: 'Beri Ulasan & Rating',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReviewScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.star_rate_rounded,
                            color: OpenTuneColors.purple,
                            size: 25,
                          ),
                        ),

                        IconButton(
                          tooltip: 'Favorit',
                          onPressed: () {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                          },
                          icon: Icon(
                            _isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isLiked
                                ? OpenTuneColors.purple
                                : OpenTuneColors.muted,
                            size: 25,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Progress slider
                    ValueListenableBuilder<double>(
                      valueListenable: openTuneProgress,
                      builder: (context, progress, _) {
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12,
                                ),
                              ),
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                activeColor: OpenTuneColors.purple,
                                inactiveColor: const Color(0xFFE6E6EB),
                                onChanged: (value) {
                                  openTuneProgress.value = value;
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTime(_duration * progress),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: OpenTuneColors.muted,
                                  ),
                                ),
                                Text(
                                  _formatTime(_duration),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: OpenTuneColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 15),

                    // Playback controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.shuffle_rounded,
                            color: OpenTuneColors.muted,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: OpenTuneColors.text,
                            size: 31,
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: openTuneIsPlaying,
                          builder: (context, isPlaying, _) {
                            return InkWell(
                              onTap: () {
                                openTuneIsPlaying.value = !isPlaying;
                              },
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      OpenTuneColors.purpleLight,
                                      OpenTuneColors.purple,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: OpenTuneColors.text,
                            size: 31,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.repeat_rounded,
                            color: OpenTuneColors.muted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Volume
                    Row(
                      children: [
                        const Icon(
                          Icons.volume_down_rounded,
                          color: OpenTuneColors.muted,
                          size: 20,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5,
                              ),
                            ),
                            child: Slider(
                              value: _volume,
                              activeColor: OpenTuneColors.purple,
                              inactiveColor: const Color(0xFFE6E6EB),
                              onChanged: (value) {
                                setState(() {
                                  _volume = value;
                                });
                              },
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.volume_up_rounded,
                          color: OpenTuneColors.muted,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${(_volume * 100).round()}%',
                          style: const TextStyle(
                            color: OpenTuneColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
