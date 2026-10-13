import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

// ─── Dummy Data ───────────────────────────────────────────────────────────────

const String _dummyName = 'Nazril Adrian';
const String _dummyEmail = 'nazril@dummy.com';
const String _dummyAvatar = 'https://picsum.photos/seed/nazril/200/200';

const List<Map<String, String>> _topArtists = [
  {'name': 'Radiohead', 'img': 'https://picsum.photos/seed/art1/200/200'},
  {'name': 'Coldplay', 'img': 'https://picsum.photos/seed/art2/200/200'},
  {'name': 'Imagine Dragons', 'img': 'https://picsum.photos/seed/art3/200/200'},
  {'name': 'Linkin Park', 'img': 'https://picsum.photos/seed/art4/200/200'},
  {'name': 'The Weeknd', 'img': 'https://picsum.photos/seed/art5/200/200'},
];

const List<Map<String, String>> _recentlyPlayed = [
  {'title': 'Creep', 'img': 'https://picsum.photos/seed/song1/200/200'},
  {'title': 'Yellow', 'img': 'https://picsum.photos/seed/song2/200/200'},
  {'title': 'Believer', 'img': 'https://picsum.photos/seed/song3/200/200'},
  {'title': 'Numb', 'img': 'https://picsum.photos/seed/song4/200/200'},
];

const List<Map<String, String>> _myPlaylists = [
  {'title': 'Chill Vibes', 'img': 'https://picsum.photos/seed/pl1/200/200'},
  {'title': 'Workout Mix', 'img': 'https://picsum.photos/seed/pl2/200/200'},
  {'title': 'Late Night', 'img': 'https://picsum.photos/seed/pl3/200/200'},
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF303030),
                  ),
                ),
              ),
              // ── Header Card ─────────────────────────────────────────────────
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB39DDB), Color(0xFFD8B4FE)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Avatar
                    ClipOval(
                      child: Image.network(
                        _dummyAvatar,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: const Color(0xFF7C3AED),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Name
                    const Text(
                      _dummyName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    const Text(
                      _dummyEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4C1D95),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Edit Profile Button
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B21B6),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Top Artist This Month ────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Top artist this month',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _topArtists.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final artist = _topArtists[index];
                    return Column(
                      children: [
                        ClipOval(
                          child: Image.network(
                            artist['img']!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 72,
                              height: 72,
                              color: const Color(0xFF7C3AED),
                              child: const Icon(Icons.person,
                                  color: Colors.white, size: 36),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          artist['name']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                        const Text(
                          'Artist',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ── Recently Played & My Playlist ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recently Played
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recently Played',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _recentlyPlayed.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _recentlyPlayed[index]['img']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFF7C3AED),
                                    child: const Icon(Icons.music_note,
                                        color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // My Playlist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Playlist',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _myPlaylists.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _myPlaylists[index]['img']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFA855F7),
                                    child: const Icon(Icons.queue_music,
                                        color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Logout Button ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7C3AED)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    icon: const Icon(Icons.logout,
                        color: Color(0xFF7C3AED), size: 20),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
