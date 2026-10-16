import 'package:flutter/material.dart';

import '../screens/player/full_screen_player_screen.dart';
import 'opentune_ui.dart';
import 'player_state.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  void _openPlayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FullScreenPlayerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 7),
      child: Material(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(11),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openPlayer(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 4, 7),
                child: Row(
                  children: [
                    const SongCover(
                      coverImage: 'assets/images/covers/setsunarensa_cover.jpg',
                      width: 43,
                      height: 43,
                      radius: 6,
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Setsunarensa',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: OpenTuneColors.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Radwimps',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: OpenTuneColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 29,
                        height: 36,
                      ),
                      onPressed: () {},
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: OpenTuneColors.text,
                        size: 21,
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
                            width: 35,
                            height: 35,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
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
                              size: 22,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 29,
                        height: 36,
                      ),
                      onPressed: () {},
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: OpenTuneColors.text,
                        size: 21,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 36,
                      ),
                      onPressed: () => _openPlayer(context),
                      tooltip: 'Buka pemutar layar penuh',
                      icon: const Icon(
                        Icons.open_in_full_rounded,
                        color: OpenTuneColors.muted,
                        size: 17,
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<double>(
                valueListenable: openTuneProgress,
                builder: (context, progress, _) {
                  return LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                    backgroundColor: const Color(0xFFEDEDF1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      OpenTuneColors.purple,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
