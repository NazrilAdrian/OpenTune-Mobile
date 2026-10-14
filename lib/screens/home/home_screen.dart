import 'package:flutter/material.dart';

import '../../widgets/opentune_ui.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const HomeScreen({
    super.key,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenTuneColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: logo + nama + akun.
              Row(
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: OpenTuneColors.purpleLight,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.headphones_rounded,
                      color: OpenTuneColors.purple,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 9),

                  const Text(
                    'OpenTune',
                    style: TextStyle(
                      color: OpenTuneColors.purple,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const Spacer(),

                  // Menggantikan ikon lonceng menjadi akun.
                  InkWell(
                    onTap: onProfileTap,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: OpenTuneColors.border,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://picsum.photos/seed/opentune-profile/100',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person_rounded,
                              color: OpenTuneColors.purple,
                              size: 25,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 29),

              _SongSection(
                title: 'Recommendation',
                tracks: recommendationTracks,
              ),

              const SizedBox(height: 27),

              _SongSection(
                title: 'Just Uploaded',
                tracks: uploadedTracks,
              ),

              const SizedBox(height: 27),

              _SongSection(
                title: 'Most Listened This Month',
                tracks: monthlyTracks,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongSection extends StatelessWidget {
  final String title;
  final List<TrackData> tracks;

  const _SongSection({
    required this.title,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: OpenTuneColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 19,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 137,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tracks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, index) {
              final track = tracks[index];

              return SizedBox(
                width: 108,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SongCover(
                      seed: track.seed,
                      width: 108,
                      height: 88,
                      radius: 5,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: OpenTuneColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: OpenTuneColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
