import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_config.dart';
import '../../../features/auth/data/auth_profile_repository.dart';
import '../../../features/profile/data/models/user_model.dart';
import '../../../navigation/custom_navbar.dart';
import '../../../screens/auth/login_screen.dart';
import '../../../screens/admin/admin_screen.dart';
import 'password_recovery_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSubscription;
  Session? _session;
  bool _isLoading = true;
  bool _isPasswordRecovery = false;

  @override
  void initState() {
    super.initState();
    _session = SupabaseConfig.client.auth.currentSession;
    _authSubscription =
        SupabaseConfig.client.auth.onAuthStateChange.listen((authState) {
      if (!mounted) return;
      setState(() {
        _session = authState.session;
        _isLoading = false;
        if (authState.event == AuthChangeEvent.passwordRecovery) {
          _isPasswordRecovery = true;
        } else if (authState.event == AuthChangeEvent.signedOut) {
          _isPasswordRecovery = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _completePasswordRecovery() {
    setState(() => _isPasswordRecovery = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isPasswordRecovery) {
      return PasswordRecoveryScreen(
        onCompleted: _completePasswordRecovery,
      );
    }

    if (_session != null) {
      return _AuthenticatedLanding(
        key: ValueKey(_session!.user.id),
      );
    }
    return const LoginScreen();
  }
}

class _AuthenticatedLanding extends StatefulWidget {
  const _AuthenticatedLanding({super.key});

  @override
  State<_AuthenticatedLanding> createState() => _AuthenticatedLandingState();
}

class _AuthenticatedLandingState extends State<_AuthenticatedLanding> {
  final _repository = AuthProfileRepository();
  late Future<UserModel?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _repository.getCurrentProfile();
  }

  void _retry() {
    setState(() {
      _profileFuture = _repository.getCurrentProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _AuthGateError(
            message: 'Profil gagal dimuat: ${snapshot.error}',
            onRetry: _retry,
          );
        }

        final profile = snapshot.data;
        if (profile == null) {
          return _AuthGateError(
            message: 'Profil akun tidak ditemukan di tabel users.',
            onRetry: _retry,
          );
        }

        if (profile.role.toLowerCase() == 'admin') {
          return const AdminScreen();
        }
        return const CustomNavbar();
      },
    );
  }
}

class _AuthGateError extends StatelessWidget {
  const _AuthGateError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
