import 'package:flutter/material.dart';
import '../../widgets/profile_dropdown_button.dart';
import '../auth/login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController =
      TextEditingController(text: 'Alexander The Great');
  final TextEditingController _emailController =
      TextEditingController(text: 'email@example.com');

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ─── Confirm Delete Dialog ─────────────────────────────────────────────────
  // Pop out confirm password dengan background putih (bukan hitam)
  void _showDeleteConfirmDialog() {
    final TextEditingController passwordController = TextEditingController();
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      // Background overlay putih transparan (bukan hitam gelap)
      barrierColor: Colors.white.withValues(alpha: 0.78),
      builder: (dialogContext) {
        bool hidePassword = true;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFF3F4F6), width: 1.5),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 390),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Confirm Account Deletion',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB91C1C),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Enter your password to confirm account deletion',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Password Label
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '****************',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 2,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF6B7280),
                            size: 20,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFDC2626),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Actions
                    Row(
                      children: [
                        // Confirm Delete (Red)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              // Success delete, navigate to login
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Account permanently deleted.'),
                                  backgroundColor: Color(0xFFDC2626),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE02424),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Confirm Delete',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Cancel (Grey)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8E8E93),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 13,
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
      },
    );
  }

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
              currentScreen: CurrentScreenType.accountSetting,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title: Account Setting
              const Text(
                'Account Setting',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F0F1A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 18),

              // ── 1. Edit Profile Card ───────────────────────────────────────
              Container(
                width: double.infinity,
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
                      color: const Color(0xFFC7B8F5).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F0F1A),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile Photo Section
                    const Text(
                      'Profile Photo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── STACK WIDGET (Materi Dosen) ──────────────────────
                        // Stack digunakan untuk menumpuk ikon kamera di atas foto profil
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Layer 1: Avatar Bulat
                            ClipOval(
                              child: Image.asset(
                                'assets/images/profile_picture.jpg',
                                width: 92,
                                height: 92,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Layer 2: Semi-transparent Overlay with Camera Icon
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // ── END STACK WIDGET ─────────────────────────────────

                        const SizedBox(width: 18),

                        // Change Photo Button
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Change photo clicked'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Text(
                            'Change Photo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5634EC),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    const Text(
                      'Format: JPG, PNG. Max 2MB',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Account Details Section
                    const Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Username
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your email or username',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF5634EC),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Email Address
                    const Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your email or username',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF5634EC),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Save Changes & Cancel Buttons
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Changes saved successfully!'),
                                backgroundColor: Color(0xFF5634EC),
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5634EC),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 13,
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

              const SizedBox(height: 24),

              // ── 2. Danger Zone Section ─────────────────────────────────────
              const Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F0F1A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFE4E6),
                      Color(0xFFFECDD3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Permanently Delete Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFDC2626),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This action is permanent and cannot be undone. All your personal data, playlists, and account settings will be permanently deleted.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showDeleteConfirmDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE02424),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
