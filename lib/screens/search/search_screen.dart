
import 'package:flutter/material.dart';
import '../../widgets/opentune_ui.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Poppins',
            ),
      ),
      child: Scaffold(
        backgroundColor: OpenTuneColors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
            children: [
              const Text(
                'Search',
                style: TextStyle(
                  color: OpenTuneColors.text,
                  fontSize: 26,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Find your favorite songs and albums.',
                style: TextStyle(
                  color: OpenTuneColors.muted,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 21),

              // Search bar
              TextField(
                showCursor: true,
                enableInteractiveSelection: true,
                style: const TextStyle(
                  color: OpenTuneColors.text,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
                cursorColor: OpenTuneColors.purple,
                decoration: InputDecoration(
                  hintText: 'Search song or album...',
                  hintStyle: const TextStyle(
                    color: OpenTuneColors.muted,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: OpenTuneColors.purple,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: OpenTuneColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: OpenTuneColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                      color: OpenTuneColors.purple,
                      width: 1.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Recently played heading
              const Text(
                'Recently Played',
                style: TextStyle(
                  color: OpenTuneColors.text,
                  fontSize: 17,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),

              // Recently played songs
              _RecentlyPlayedSong(
                title: 'Setsunarensa',
                artist: 'RADWIMPS',
                coverImage:
                    'assets/images/covers/setsunarensa_cover.jpg',
              ),
              const SizedBox(height: 12),
              _RecentlyPlayedSong(
                title: 'Under Blue',
                artist: 'Eve',
                coverImage:
                    'assets/images/covers/under_blue_cover.jpg',
              ),
              const SizedBox(height: 12),
              _RecentlyPlayedSong(
                title: 'Dramaturgy',
                artist: 'Eve',
                coverImage: 'assets/images/covers/dramaturgy_cover.jpg',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentlyPlayedSong extends StatelessWidget {
  final String title;
  final String artist;
  final String? coverImage;

  const _RecentlyPlayedSong({
    required this.title,
    required this.artist,
    required this.coverImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: OpenTuneColors.border,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // Cover lagu
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: coverImage != null
                ? Image.asset(
                    coverImage!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _coverPlaceholder();
                    },
                  )
                : _coverPlaceholder(),
          ),

          const SizedBox(width: 12),

          // Judul lagu dan artist
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: OpenTuneColors.text,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: OpenTuneColors.muted,
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // Tombol hapus riwayat di sebelah kanan
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title dihapus dari riwayat.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(
              Icons.close_rounded,
              size: 19,
            ),
            color: OpenTuneColors.muted,
            tooltip: 'Hapus dari riwayat',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 30,
              minHeight: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: OpenTuneColors.purplePale,
      alignment: Alignment.center,
      child: const Icon(
        Icons.music_note_rounded,
        color: OpenTuneColors.purple,
        size: 24,
      ),
    );
  }
}
