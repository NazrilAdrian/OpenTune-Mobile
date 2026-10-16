
import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/manage/manage_screen.dart';
import '../screens/playlist/playlist_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/upload/album_upload_screen.dart';
import '../screens/upload/song_upload_screen.dart';
import '../widgets/mini_player_bar.dart';
import '../widgets/opentune_ui.dart';

class CustomNavbar extends StatefulWidget {
  const CustomNavbar({super.key});

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  int currentIndex = 0;

  // ============================================================
  // MAIN SCREENS
  // ============================================================

  List<Widget> get _screens => [
        HomeScreen(onProfileTap: _openProfile),
        const SearchScreen(),
        const PlaylistScreen(),
        const ManageScreen(),
      ];

  // ============================================================
  // NAVIGATION
  // ============================================================

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

  // ============================================================
  // UPLOAD MENU
  // ============================================================

  void _showUploadMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 28),
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
                // Bottom sheet handle
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

                // Title and description
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload',
                        style: TextStyle(
                          fontSize: 21,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: OpenTuneColors.text,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Choose the content you want to add.',
                        style: TextStyle(
                          color: OpenTuneColors.muted,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 19),

                // Upload Song
                _UploadMenuOption(
                  icon: Icons.music_note_rounded,
                  title: 'Upload Song',
                  subtitle: 'Add a single song',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openSongUpload();
                  },
                ),

                const SizedBox(height: 10),

                // Upload Album
                _UploadMenuOption(
                  icon: Icons.album_rounded,
                  title: 'Upload Album',
                  subtitle: 'Add an album with its songs',
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

  // ============================================================
  // REGULAR NAVIGATION ITEM
  // ============================================================

  Widget _navItem({
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color =
        selected ? OpenTuneColors.purple : OpenTuneColors.muted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 62,
          child: Center(
            child: _buildRegularNavItem(
              label: label,
              icon: icon,
              activeIcon: activeIcon,
              selected: selected,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UPLOAD BUTTON
  // ============================================================

  Widget _buildUploadButton() {
    return Container(
      width: 66,
      height: 70,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
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
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_upload_rounded,
            color: Colors.white,
            size: 25,
          ),
          SizedBox(height: 3),
          Text(
            'Upload',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION ITEM: ICON AND LABEL
  // ============================================================

  Widget _buildRegularNavItem({
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required bool selected,
    required Color color,
  }) {
    return SizedBox(
      height: 58,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 34,
            child: Center(
              child: Icon(
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
              color: color,
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION BAR
  // ============================================================

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini player
            const MiniPlayerBar(),

            // Top border of the navigation bar
            SizedBox(
              height: 1,
              child: CustomPaint(
                painter: _NavbarTopBorderPainter(),
                child: const SizedBox.expand(),
              ),
            ),

            // Navigation area
            SizedBox(
              height: 62,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
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

                        // Space for the Upload button
                        const Expanded(
                          child: SizedBox.shrink(),
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

                  // Floating Upload button in the center
                  Positioned(
                    top: -8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: _showUploadMenu,
                          borderRadius: BorderRadius.circular(18),
                          child: _buildUploadButton(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenTuneColors.background,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

// ================================================================
// UPLOAD MENU OPTION
// ================================================================

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
              // Menu icon
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

              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: OpenTuneColors.text,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: OpenTuneColors.muted,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
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

// ================================================================
// NAVBAR TOP BORDER PAINTER
// ================================================================

class _NavbarTopBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = OpenTuneColors.border
      ..strokeWidth = 1;

    final y = size.height / 2;

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _NavbarTopBorderPainter oldDelegate,
  ) {
    return false;
  }
}
