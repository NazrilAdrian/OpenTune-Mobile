import 'package:flutter/material.dart';
import '../features/auth/data/auth_profile_repository.dart';
import '../features/profile/data/models/user_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';

enum CurrentScreenType {
  home,
  profile,
  accountSetting,
}

class ProfileDropdownButton extends StatefulWidget {
  final double size;
  final CurrentScreenType currentScreen;

  const ProfileDropdownButton({
    super.key,
    this.size = 40,
    this.currentScreen = CurrentScreenType.home,
  });

  @override
  State<ProfileDropdownButton> createState() => _ProfileDropdownButtonState();
}

class _ProfileDropdownButtonState extends State<ProfileDropdownButton> {
  final _repository = AuthProfileRepository();
  late Future<UserModel?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _repository.getCurrentProfile();
  }

  void _refreshProfile() {
    if (!mounted) return;
    setState(() {
      _profileFuture = _repository.getCurrentProfile();
    });
  }

  Widget _buildAvatar() {
    return FutureBuilder<UserModel?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final imageUrl = profile?.profilePicture;
        if (imageUrl == null || imageUrl.isEmpty) {
          return _buildInitialAvatar(profile?.username);
        }

        return ClipOval(
          child: Image.network(
            imageUrl,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _buildInitialAvatar(profile?.username),
          ),
        );
      },
    );
  }

  Widget _buildInitialAvatar(String? username) {
    final trimmedUsername = username?.trim() ?? '';
    final initial = trimmedUsername.isEmpty
        ? '?'
        : trimmedUsername.substring(0, 1).toUpperCase();

    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFE9D5FF),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Color(0xFF5634EC),
          fontSize: widget.size * 0.48,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profile Menu',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      onSelected: (value) async {
        if (value == 'logout') {
          _showConfirmLogoutDialog(context);
        } else if (value == 'profile') {
          if (widget.currentScreen == CurrentScreenType.profile) {
            // Already on profile
            return;
          }
          if (widget.currentScreen == CurrentScreenType.accountSetting) {
            await Navigator.pushReplacement<void, void>(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          } else {
            await Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
          _refreshProfile();
        } else if (value == 'account_setting') {
          if (widget.currentScreen == CurrentScreenType.accountSetting) {
            return;
          }
          final updated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
          if (updated == true) {
            _refreshProfile();
          }
        }
      },
      itemBuilder: (context) => [
        // ── Header: Name & Account Type ──
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: FutureBuilder<UserModel?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              final profile = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.username ?? 'OpenTune User',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F0F1A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile?.role ?? 'Account',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const PopupMenuDivider(height: 1),
        // ── My Profile ──
        const PopupMenuItem<String>(
          value: 'profile',
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFF374151), size: 18),
              SizedBox(width: 10),
              Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        // ── Account Setting ──
        const PopupMenuItem<String>(
          value: 'account_setting',
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.settings_outlined, color: Color(0xFF374151), size: 18),
              SizedBox(width: 10),
              Text(
                'Account Setting',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        // ── Logout ──
        const PopupMenuItem<String>(
          value: 'logout',
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFDC2626), size: 18),
              SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFDC2626),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      child: ClipOval(
        child: _buildAvatar(),
      ),
    );
  }

  void _showConfirmLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top icon in soft pink circle
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE4E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),

                // Title: Confirm Logout
                const Text(
                  'Confirm Logout',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle / message
                const Text(
                  'Are you sure you want to log out? You will need to log back in to access your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Poppins',
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons: Cancel & Logout
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(
                            color: Color(0xFF6B7280),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B5563),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          try {
                            await AuthProfileRepository().signOut();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error.toString())),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
