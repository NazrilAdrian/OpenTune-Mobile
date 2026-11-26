import 'package:flutter/material.dart';

import '../data/auth_profile_repository.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({
    required this.onCompleted,
    super.key,
  });

  final VoidCallback onCompleted;

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _repository = AuthProfileRepository();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSaving = false;
  bool _isCompleted = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_passwordController.text.length < 8) {
      _showMessage('Password minimal 8 karakter.');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Konfirmasi password tidak cocok.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _repository.updatePassword(_passwordController.text);
      if (mounted) setState(() => _isCompleted = true);
    } catch (error) {
      if (mounted) _showMessage('Gagal mengubah password: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _isCompleted ? _buildCompletedView() : _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo_opentune.png',
          height: 60,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.headphones,
            size: 56,
            color: Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Reset password',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0F0F1A),
            fontFamily: 'Poppins',
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Create a new password for your account.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 36),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(
            color: Color(0xFF0F0F1A),
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
          decoration: _passwordDecoration(
            labelText: 'New password',
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          style: const TextStyle(
            color: Color(0xFF0F0F1A),
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
          decoration: _passwordDecoration(
            labelText: 'Confirm new password',
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _updatePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B21B6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            child: Text(
              _isSaving ? 'Saving...' : 'Update password',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _passwordDecoration({required String labelText}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontFamily: 'Poppins',
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildCompletedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo_opentune.png',
          height: 60,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.headphones,
            size: 56,
            color: Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(height: 32),
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 56,
          color: Color(0xFF7C3AED),
        ),
        const SizedBox(height: 20),
        const Text(
          'Password updated',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0F0F1A),
            fontFamily: 'Poppins',
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: widget.onCompleted,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B21B6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
