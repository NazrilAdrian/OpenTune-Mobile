import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/playlist/playlist_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/manage/manage_screen.dart';
import '../screens/upload/song_upload_screen.dart';
import '../screens/upload/album_upload_screen.dart';
import '../widgets/mini_player_bar.dart';
import '../widgets/opentune_ui.dart';

class CustomNavbar extends StatefulWidget {
  const CustomNavbar({super.key});

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  int currentIndex = 0;

  // Upload bukan tab terpisah. Tombolnya membuka pilihan.
  List<Widget> get _screens => [
        HomeScreen(onProfileTap: _openProfile),
        const SearchScreen(),
        const PlaylistScreen(),
        const ManageScreen(),
      ];

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _openSongUpload() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SongUploadScreen(),
      ),
    );
  }

  void _openAlbumUpload() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AlbumUploadScreen(),
      ),
    );
  }

  void _showUploadMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(18),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDADAE0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Upload',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: OpenTuneColors.text,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Pilih konten yang ingin kamu tambahkan.',
                  style: TextStyle(
                    color: OpenTuneColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 19),
                _UploadMenuOption(
                  icon: Icons.music_note_rounded,
                  title: 'Upload Lagu',
                  subtitle: 'Tambahkan satu lagu',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openSongUpload();
                  },
                ),
                const SizedBox(height: 10),
                _UploadMenuOption(
                  icon: Icons.album_rounded,
                  title: 'Upload Album',
                  subtitle: 'Tambahkan album beserta lagunya',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openAlbumUpload();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navItem({
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required bool selected,
    required VoidCallback onTap,
    bool isUpload = false,
  }) {
    final color = selected ? OpenTuneColors.purple : OpenTuneColors.muted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tinggi area ikon disamakan supaya label sejajar.
              SizedBox(
                width: 36,
                height: 34,
                child: Center(
                  child: isUpload
                      ? Container(
                          width: 34,
                          height: 34,
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
                          child: const Icon(
                            Icons.cloud_upload_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      : Icon(
                          selected ? activeIcon : icon,
                          color: color,
                          size: 23,
                        ),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUpload ? OpenTuneColors.purple : color,
                  fontSize: 10,
                  fontWeight:
                      selected || isUpload ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenTuneColors.background,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini-player berada di atas navigasi.
              const MiniPlayerBar(),

              Container(
                height: 1,
                color: OpenTuneColors.border,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    _navItem(
                      label: 'Home',
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      selected: currentIndex == 0,
                      onTap: () {
                        setState(() => currentIndex = 0);
                      },
                    ),
                    _navItem(
                      label: 'Search',
                      icon: Icons.search_rounded,
                      activeIcon: Icons.search_rounded,
                      selected: currentIndex == 1,
                      onTap: () {
                        setState(() => currentIndex = 1);
                      },
                    ),
                    _navItem(
                      label: 'Upload',
                      icon: Icons.cloud_upload_rounded,
                      activeIcon: Icons.cloud_upload_rounded,
                      selected: false,
                      isUpload: true,
                      onTap: _showUploadMenu,
                    ),
                    _navItem(
                      label: 'Playlist',
                      icon: Icons.queue_music_rounded,
                      activeIcon: Icons.queue_music_rounded,
                      selected: currentIndex == 2,
                      onTap: () {
                        setState(() => currentIndex = 2);
                      },
                    ),
                    _navItem(
                      label: 'Manage',
                      icon: Icons.library_music_outlined,
                      activeIcon: Icons.library_music_rounded,
                      selected: currentIndex == 3,
                      onTap: () {
                        setState(() => currentIndex = 3);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadMenuOption extends StatelessWidget {
  const _UploadMenuOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OpenTuneColors.background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: OpenTuneColors.purplePale,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  color: OpenTuneColors.purple,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: OpenTuneColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: OpenTuneColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: OpenTuneColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
