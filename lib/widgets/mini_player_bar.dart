import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

import '../core/services/audio_handler.dart';
import '../screens/player/full_screen_player_screen.dart';
import 'opentune_ui.dart';

class MiniPlayerBar extends StatefulWidget {
  const MiniPlayerBar({super.key});

  @override
  State<MiniPlayerBar> createState() => _MiniPlayerBarState();
}

class _MiniPlayerBarState extends State<MiniPlayerBar> {
  bool _isOpening = false;

  double _dragDistance = 0;

  // ============================================================
  // MEMBUKA FULL SCREEN PLAYER DENGAN ANIMASI
  // ============================================================

  Future<void> _openPlayer(BuildContext context) async {
    if (_isOpening) return;

    setState(() {
      _isOpening = true;
    });

    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const FullScreenPlayerScreen();
        },

        // Durasi animasi saat membuka
        transitionDuration: const Duration(milliseconds: 420),

        // Durasi animasi saat menutup
        reverseTransitionDuration: const Duration(milliseconds: 320),

        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(curvedAnimation);

          final scaleAnimation = Tween<double>(
            begin: 0.985,
            end: 1.0,
          ).animate(curvedAnimation);

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            ),
          );
        },
      ),
    );

    if (!mounted) return;

    setState(() {
      _isOpening = false;
    });
  }

  // ============================================================
  // GESTURE USAP KE ATAS
  // ============================================================

  void _onVerticalDragStart(DragStartDetails details) {
    _dragDistance = 0;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _dragDistance += details.delta.dy;
  }

  void _onVerticalDragEnd(
    BuildContext context,
    DragEndDetails details,
  ) {
    final bool isSwipeUp =
        _dragDistance < -40 || details.velocity.pixelsPerSecond.dy < -300;

    if (isSwipeUp) {
      _openPlayer(context);
    }

    _dragDistance = 0;
  }

  // ============================================================
  // BUILD MINI PLAYER
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F8FA),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,

          // Ketuk Mini Player untuk membuka layar penuh
          onTap: () => _openPlayer(context),

          // Gesture usap ke atas
          onVerticalDragStart: _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: (details) {
            _onVerticalDragEnd(context, details);
          },

          child: AnimatedScale(
            scale: _isOpening ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: Material(
              color: Colors.white,
              elevation: 5,
              shadowColor: Colors.black.withValues(alpha: 0.10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(
                  color: Color(0xFFE3E5EA),
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Album cover
                    StreamBuilder<MediaItem?>(
                      stream: openTuneAudioHandler.mediaItem,
                      builder: (context, snapshot) => SongCover(
                        coverImage: snapshot.data?.artUri?.toString() ??
                            'assets/images/covers/setsunarensa_cover.jpg',
                        width: 43,
                        height: 43,
                        radius: 7,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Judul lagu dan artis
                    Expanded(
                      child: StreamBuilder<MediaItem?>(
                        stream: openTuneAudioHandler.mediaItem,
                        builder: (context, snapshot) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              snapshot.data?.title ?? 'Pilih lagu',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: OpenTuneColors.text,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              snapshot.data?.artist ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: OpenTuneColors.muted,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Tombol mute / unmute
                    StreamBuilder<double>(
                      stream: openTuneAudioHandler.player.volumeStream,
                      builder: (context, snapshot) {
                        final isMuted = (snapshot.data ?? 1) == 0;
                        return IconButton(
                          onPressed: () =>
                              openTuneAudioHandler.setMuted(!isMuted),
                          tooltip: isMuted ? 'Aktifkan suara' : 'Mute',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 30,
                            height: 43,
                          ),
                          icon: Icon(
                            isMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: OpenTuneColors.muted,
                            size: 21,
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 8),

                    // Tombol Play / Pause
                    StreamBuilder<PlaybackState>(
                      stream: openTuneAudioHandler.playbackState,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data?.playing ?? false;
                        return IconButton(
                          onPressed: openTuneAudioHandler.queue.value.isEmpty
                              ? null
                              : () => isPlaying
                                  ? openTuneAudioHandler.pause()
                                  : openTuneAudioHandler.play(),
                          tooltip: isPlaying ? 'Pause' : 'Play',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 43,
                          ),
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: OpenTuneColors.purple,
                            size: 31,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
