import 'package:flutter/material.dart';

class OpenTuneColors {
  static const background = Color(0xFFF7F8FA);
  static const card = Colors.white;
  static const text = Color(0xFF303030);
  static const muted = Color(0xFF929292);
  static const border = Color(0xFFE3E5EA);
  static const purple = Color(0xFF5634EC);
  static const purpleLight = Color(0xFFD2A6FB);
  static const purplePale = Color(0xFFF2EBFF);
}

class TrackData {
  final String title;
  final String artist;
  final String seed;

  const TrackData({
    required this.title,
    required this.artist,
    required this.seed,
  });
}

// Empat lagu per section, menyesuaikan contoh website.

const recommendationTracks = [
  TrackData(
    title: 'Setsunarensa',
    artist: 'Radwimps',
    seed: 'setsunarensa',
  ),
  TrackData(
    title: 'Dramaturgy',
    artist: 'Eve',
    seed: 'dramaturgy',
  ),
  TrackData(
    title: 'Starlight Parade',
    artist: 'Sekai No Owari',
    seed: 'starlight-parade',
  ),
  TrackData(
    title: 'ODO',
    artist: 'Ado',
    seed: 'odo-ado',
  ),
];

const uploadedTracks = [
  TrackData(
    title: 'Saikai',
    artist: 'Vaundy',
    seed: 'saikai',
  ),
  TrackData(
    title: 'Fly Away',
    artist: 'Vaundy',
    seed: 'fly-away',
  ),
  TrackData(
    title: 'Tokyo Flash',
    artist: 'Vaundy',
    seed: 'tokyo-flash',
  ),
  TrackData(
    title: 'Let Me Hear',
    artist: 'Fear and Loathing in Las Vegas',
    seed: 'let-me-hear',
  ),
];

const monthlyTracks = [
  TrackData(
    title: 'Thriller',
    artist: 'Michael Jackson',
    seed: 'thriller',
  ),
  TrackData(
    title: 'Greatest Hits',
    artist: 'Queen',
    seed: 'queen-greatest-hits',
  ),
  TrackData(
    title: 'After Hours',
    artist: 'The Weeknd',
    seed: 'after-hours',
  ),
  TrackData(
    title: 'Island in the Sun',
    artist: 'Weezer',
    seed: 'island-in-the-sun',
  ),
];

const searchSongTracks = [
  TrackData(
    title: 'Dramaturgy',
    artist: 'Eve',
    seed: 'dramaturgy',
  ),
  TrackData(
    title: 'Kaikai Kitan',
    artist: 'Eve',
    seed: 'kaikai-kitan',
  ),
  TrackData(
    title: 'Bokurano',
    artist: 'Eve',
    seed: 'bokurano',
  ),
  TrackData(
    title: 'Fight Song',
    artist: 'Eve',
    seed: 'fight-song',
  ),
  TrackData(
    title: 'Last Dance',
    artist: 'Eve',
    seed: 'last-dance',
  ),
  TrackData(
    title: 'Avant',
    artist: 'Eve',
    seed: 'avant',
  ),
];

const searchAlbumTracks = [
  TrackData(
    title: 'Bunka',
    artist: 'Eve',
    seed: 'bunka-album',
  ),
  TrackData(
    title: 'Under Blue',
    artist: 'Eve',
    seed: 'under-blue',
  ),
  TrackData(
    title: 'Kaizin',
    artist: 'Eve',
    seed: 'kaizin',
  ),
  TrackData(
    title: 'Smile',
    artist: 'Eve',
    seed: 'smile-album',
  ),
  TrackData(
    title: 'Otogi',
    artist: 'Eve',
    seed: 'otogi',
  ),
  TrackData(
    title: 'Kaikai Kitan',
    artist: 'Eve',
    seed: 'kaikai-kitan-album',
  ),
];

/// Cover placeholder untuk wireframe.
/// Gambar jaringan hanya contoh visual; tidak terhubung ke backend.
class SongCover extends StatelessWidget {
  final String seed;
  final double width;
  final double height;
  final double radius;
  final IconData fallbackIcon;

  const SongCover({
    super.key,
    required this.seed,
    this.width = 110,
    this.height = 95,
    this.radius = 8,
    this.fallbackIcon = Icons.music_note_rounded,
  });

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
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
        fallbackIcon,
        size: 38,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          'https://picsum.photos/seed/$seed/480/400',
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _placeholder();
          },
          errorBuilder: (context, error, stackTrace) {
            return _placeholder();
          },
        ),
      ),
    );
  }
}

class OpenTunePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const OpenTunePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: OpenTuneColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: OpenTuneColors.border,
        ),
      ),
      child: child,
    );
  }
}

class WireframeTextField extends StatelessWidget {
  final String label;
  final String hint;
  final String? initialValue;
  final int maxLines;

  const WireframeTextField({
    super.key,
    required this.label,
    required this.hint,
    this.initialValue,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: OpenTuneColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          style: const TextStyle(
            color: OpenTuneColors.text,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: OpenTuneColors.muted,
              fontSize: 13,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: OpenTuneColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: OpenTuneColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: OpenTuneColors.purple,
                width: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                OpenTuneColors.purpleLight,
                OpenTuneColors.purple,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 19),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WireframeUploadTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const WireframeUploadTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF6F6F8),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: OpenTuneColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: OpenTuneColors.purplePale,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: OpenTuneColors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: OpenTuneColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: OpenTuneColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.upload_file_rounded,
                color: OpenTuneColors.muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
