import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ──────────────────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/images/logo_opentune.png',
                  height: 60,
                  errorBuilder: (_, __, ___) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF7C3AED), width: 2),
                        ),
                        child: const Icon(Icons.headphones,
                            color: Color(0xFF7C3AED), size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'OpenTune',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Title ─────────────────────────────────────────────────────
              const Text(
                'Create an Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F0F1A),
                  fontFamily: 'Poppins',
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Join OpenTune to discover, create, and\nshare your music journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // ── Username Field ────────────────────────────────────────────
              _buildLabel('Username'),
              const SizedBox(height: 8),
              _buildTextField(hint: 'slimut69'),

              const SizedBox(height: 18),

              // ── Email Field ───────────────────────────────────────────────
              _buildLabel('Email  Address'),
              const SizedBox(height: 8),
              _buildTextField(
                  hint: 'user@example.com',
                  keyboardType: TextInputType.emailAddress),

              const SizedBox(height: 18),

              // ── Password Field ────────────────────────────────────────────
              Row(
                children: [
                  _buildLabel('Password'),
                  const SizedBox(width: 8),
                  const Icon(Icons.check, color: Color(0xFF7C3AED), size: 16),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: _obscurePassword,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF0F0F1A)),
                decoration: _passwordDecoration(
                  hint: '••••••••••••••',
                  isObscure: _obscurePassword,
                  onToggle: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Must be at least 8 characters long. Include an uppercase letter and a number.',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  fontFamily: 'Poppins',
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              // ── Confirm Password Field ────────────────────────────────────
              Row(
                children: [
                  _buildLabel('Confirm Password'),
                  const SizedBox(width: 8),
                  const Icon(Icons.check, color: Color(0xFF7C3AED), size: 16),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: _obscureConfirmPassword,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF0F0F1A)),
                decoration: _passwordDecoration(
                  hint: '••••••••••••••',
                  isObscure: _obscureConfirmPassword,
                  onToggle: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ── Terms Checkbox ────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _agreeToTerms,
                      activeColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "I agree to OpenTune's Terms of Service and Privacy Policy",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Sign Up Button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B21B6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Log In Link ───────────────────────────────────────────────
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7C3AED),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper: Label Text ───────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
        fontFamily: 'Poppins',
      ),
    );
  }

  // ── Helper: Standard TextField ───────────────────────────────────────────
  Widget _buildTextField({
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF0F0F1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFD1D5DB),
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // ── Helper: Password TextField ───────────────────────────────────────────
  InputDecoration _passwordDecoration({
    required String hint,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFD1D5DB),
        fontSize: 14,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: IconButton(
        icon: Icon(
          isObscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: const Color(0xFF9CA3AF),
          size: 20,
        ),
        onPressed: onToggle,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
