import 'package:flutter/material.dart';
import '../../widgets/profile_dropdown_button.dart';
import 'edit_profile_screen.dart';

// ─── Dummy Data ───────────────────────────────────────────────────────────────

const String _dummyName = 'Alexander The Great';
const String _dummyEmail = 'email@example.com';

const List<Map<String, String>> _topArtists = [
  {
    'name': 'Radiohead',
    'role': 'Artist',
    'img': 'assets/images/covers/radiohead_cover.jpg',
  },
  {
    'name': 'Drake',
    'role': 'Artist',
    'img': 'assets/images/covers/drake_cover.jpg',
  },
  {
    'name': 'Joji',
    'role': 'Artist',
    'img': 'assets/images/covers/joji_cover.jpg',
  },
  {
    'name': 'Malcolm Todd',
    'role': 'Artist',
    'img': 'assets/images/covers/malcolm_todd_cover.jpg',
  },
  {
    'name': 'Marcel',
    'role': 'Artist',
    'img': 'assets/images/covers/marcel_cover.jpg',
  },
  {
    'name': 'Daniel Ceaser',
    'role': 'Artist',
    'img': 'assets/images/covers/daniel_ceaser_cover.jpg',
  },
];

const List<Map<String, String>> _recentlyPlayed = [
  {
    'title': 'Paranoid Android',
    'artist': 'Radiohead',
    'cover': 'assets/images/covers/paranoid_android_cover.jpg',
  },
  {
    'title': 'Setsunarensa',
    'artist': 'Radwimps',
    'cover': 'assets/images/covers/setsunarensa_cover.jpg',
  },
  {
    'title': 'Dramaturgy',
    'artist': 'Eve',
    'cover': 'assets/images/covers/dramaturgy_cover.jpg',
  },
  {
    'title': 'ODO',
    'artist': 'Ado',
    'cover': 'assets/images/covers/odo_cover.jpg',
  },
];

const List<Map<String, String>> _myPlaylists = [
  {
    'title': 'Chill Hits',
    'songs': '18 Songs',
    'cover': 'assets/images/covers/paranoid_android_cover.jpg',
  },
  {
    'title': 'Rock Classics',
    'songs': '24 Songs',
    'cover': 'assets/images/covers/fly_away_cover.jpg',
  },
  {
    'title': 'Focus Flow',
    'songs': '15 Songs',
    'cover': 'assets/images/covers/starlight_parade_cover.jpg',
  },
  {
    'title': 'Late Night',
    'songs': '30 Songs',
    'cover': 'assets/images/covers/saikai_cover.jpg',
  },
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFD),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            if (Navigator.canPop(context))
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF5634EC)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
              ),
            if (Navigator.canPop(context)) const SizedBox(width: 8),
            Image.asset(
              'assets/images/logo_opentune.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF5634EC), width: 1.5),
                ),
                child: const Icon(Icons.headphones, color: Color(0xFF5634EC), size: 16),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'OpenTune',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5634EC),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ProfileDropdownButton(
              size: 38,
              currentScreen: CurrentScreenType.profile,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Hero Profile Banner ─────────────────────────────────────
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFC7B8F5),
                      Color(0xFFDCCDFE),
                      Color(0xFFEADBFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC7B8F5).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar (ClipOval + Image.network as per lecturer rule)
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/profile_picture.jpg',
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    // Name & Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            _dummyName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F0F1A),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            _dummyEmail,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4B5563),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5634EC),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. Top Artist This Month ───────────────────────────────────
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F1F5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top artist this month',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _topArtists.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final artist = _topArtists[index];
                          return Column(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    artist['img']!,
                                    width: 68,
                                    height: 68,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFFE9D5FF),
                                      child: const Icon(
                                        Icons.person,
                                        color: Color(0xFF7C3AED),
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                artist['name']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F0F1A),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                artist['role']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                  fontFamily: 'Poppins',
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

              // ── 3. Recently Played Card ────────────────────────────────────
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F1F5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recently Played',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recentlyPlayed.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final item = _recentlyPlayed[index];
                          return SizedBox(
                            width: 104,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    item['cover']!,
                                    width: 104,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 104,
                                      height: 90,
                                      color: const Color(0xFFE9D5FF),
                                      child: const Icon(
                                        Icons.music_note,
                                        color: Color(0xFF7C3AED),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['title']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F0F1A),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  item['artist']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── 4. My Plasylist Card ───────────────────────────────────────
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F1F5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Plasylist',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _myPlaylists.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final item = _myPlaylists[index];
                          return SizedBox(
                            width: 104,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    item['cover']!,
                                    width: 104,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 104,
                                      height: 90,
                                      color: const Color(0xFFDDD6FE),
                                      child: const Icon(
                                        Icons.queue_music,
                                        color: Color(0xFF7C3AED),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['title']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F0F1A),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  item['songs']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
