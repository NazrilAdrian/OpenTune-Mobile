import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFeatures() {
    final context = _featuresKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _scrollController.animateTo(
        420,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Header: Logo + Large Center Login & Sign up Buttons ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  children: [
                    // Brand Logo & Name Centered
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo_opentune.png',
                            width: 38,
                            height: 38,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF7C3AED),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.headphones,
                                color: Color(0xFF7C3AED),
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'OpenTune',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5634EC),
                              fontFamily: 'Poppins',
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Large Center Login & Sign up Buttons ──────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: const Color(0xFFE9D5FF),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Large Login Button
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  elevation: 1,
                                  shadowColor: Colors.black.withValues(alpha: 0.08),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5634EC),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Large Sign up Button
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5634EC),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  elevation: 2,
                                  shadowColor: const Color(0xFF5634EC).withValues(alpha: 0.4),
                                ),
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── 2. Hero Content Section ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Catchphrase
                    const Text(
                      'Discover,\ncreate, & share\nyour music',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F0F1A),
                        fontFamily: 'Poppins',
                        height: 1.15,
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Subtitle
                    const Text(
                      'Welcome to OpenTune. Access thousands of songs, albums, and playlist anytime. Upload your own tracks and join the rhythm.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                        fontFamily: 'Poppins',
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Action Buttons: Get Started & Learn More
                    Row(
                      children: [
                        // Get Started (Primary gradient button)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5634EC),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 3,
                            shadowColor: const Color(0xFF5634EC).withValues(alpha: 0.35),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Learn More (Outlined button with scroll to features)
                        OutlinedButton(
                          onPressed: _scrollToFeatures,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            side: const BorderSide(
                              color: Color(0xFFD1D5DB),
                              width: 1.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Text(
                            'Learn More',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5634EC),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── 3. Features Section (Scroll Down) ──────────────────────────
              Container(
                key: _featuresKey,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 36),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFD),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        'FEATURES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5634EC),
                          fontFamily: 'Poppins',
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Section Heading
                    const Text(
                      'Why Choose OpenTune?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F0F1A),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Explore all the features designed to give you the ultimate music streaming experience on mobile.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontFamily: 'Poppins',
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Feature 1: Music Streaming & Recommendations
                    _buildFeatureCard(
                      icon: Icons.headphones_rounded,
                      iconBg: const Color(0xFFEDE9FE),
                      iconColor: const Color(0xFF5634EC),
                      title: 'Stream Thousands of Tracks',
                      description:
                          'Listen to songs from top artists with curated monthly recommendations tailored to your taste.',
                    ),

                    const SizedBox(height: 14),

                    // Feature 2: Custom Playlists
                    _buildFeatureCard(
                      icon: Icons.queue_music_rounded,
                      iconBg: const Color(0xFFE0E7FF),
                      iconColor: const Color(0xFF4338CA),
                      title: 'Personalized Playlists',
                      description:
                          'Easily create, customize, and arrange your playlists. Access all your favorite jams anytime, anywhere.',
                    ),

                    const SizedBox(height: 14),

                    // Feature 3: Creator Uploads
                    _buildFeatureCard(
                      icon: Icons.cloud_upload_rounded,
                      iconBg: const Color(0xFFFCE7F3),
                      iconColor: const Color(0xFFBE185D),
                      title: 'Upload Singles & Albums',
                      description:
                          'Built for independent creators. Upload your own tracks, add custom album artwork, and share with listeners.',
                    ),

                    const SizedBox(height: 14),

                    // Feature 4: Interactive Mini Player
                    _buildFeatureCard(
                      icon: Icons.play_circle_fill_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFB45309),
                      title: 'Seamless Player Controls',
                      description:
                          'Enjoy intuitive music controls with continuous background playback, shuffle, and lyrics support.',
                    ),

                    const SizedBox(height: 32),

                    // ── Bottom Banner CTA ────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF5634EC),
                            Color(0xFF7C3AED),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5634EC).withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ready to dive into the rhythm?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Join thousands of music lovers on OpenTune today.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFE9D5FF),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF5634EC),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Create Free Account',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F0F1A),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Poppins',
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
