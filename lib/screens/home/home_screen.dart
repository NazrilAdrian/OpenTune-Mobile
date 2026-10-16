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
              // 1. Header
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo_opentune.png',
                    width: 39,
                    height: 39,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 9),
                  const Text(
                    'OpenTune',
                    style: TextStyle(
                      color: OpenTuneColors.purple,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: onProfileTap,
                    customBorder: const CircleBorder(),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/profile_picture.jpg',
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 29),

              // 2. Recommendation
              const Text(
                'Recommendation',
                style: TextStyle(
                  color: OpenTuneColors.text,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 19,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 13),
              _buildSongList(recommendationTracks),

              const SizedBox(height: 27),

              // 3. Just Uploaded
              const Text(
                'Just Uploaded',
                style: TextStyle(
                  color: OpenTuneColors.text,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 19,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 13),
              _buildSongList(uploadedTracks),

              const SizedBox(height: 27),

              // 4. Most Listened This Month
              const Text(
                'Most Listened This Month',
                style: TextStyle(
                  color: OpenTuneColors.text,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 19,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 13),
              _buildSongList(monthlyTracks),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan daftar lagu secara horizontal.
  Widget _buildSongList(List<TrackData> tracks) {
    return SizedBox(
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
                  coverImage: track.coverImage,
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
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
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
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
