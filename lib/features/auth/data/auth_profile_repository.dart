import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_config.dart';
import '../../profile/data/models/user_model.dart';

class AuthProfileRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<AuthResponse> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'username': username.trim()},
    );

    if (response.session != null) {
      await _client.auth.signOut();
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    String emailToUse = emailOrUsername.trim();

    if (!emailToUse.contains('@')) {
      final result = await _client
          .from('users')
          .select('email')
          .eq('username', emailToUse)
          .maybeSingle();

      if (result == null) {
        throw const AuthException('Username tidak ditemukan.');
      }
      emailToUse = result['email'] as String;
    }

    return await _client.auth.signInWithPassword(
      email: emailToUse,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> sendPasswordResetEmail({
    required String email,
    required String redirectTo,
  }) async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: redirectTo,
    );
  }

  Future<void> updatePassword(String password) async {
    await _client.auth.updateUser(
      UserAttributes(password: password),
    );
  }

  Future<UserModel?> getCurrentProfile() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return null;

    final data = await _client
        .from('users')
        .select()
        .eq('user_id', currentUser.id)
        .single();

    return UserModel.fromJson(data);
  }

  Future<UserModel> updateProfile({
    required String newUsername,
    XFile? newAvatarFile,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw const AuthException('Sesi login tidak ditemukan.');
    }

    String? avatarUrl;

    if (newAvatarFile != null) {
      final bytes = await newAvatarFile.readAsBytes();
      final ext = newAvatarFile.name.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final filePath = '${currentUser.id}/avatar.$ext';

      await _client.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: mimeType,
            ),
          );

      final rawUrl = _client.storage.from('avatars').getPublicUrl(filePath);
      avatarUrl = '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    }

    final updateData = <String, dynamic>{
      'username': newUsername.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (avatarUrl != null) {
      updateData['profile_picture'] = avatarUrl;
    }

    final updated = await _client
        .from('users')
        .update(updateData)
        .eq('user_id', currentUser.id)
        .select()
        .single();

    return UserModel.fromJson(updated);
  }

  Future<void> deleteAccount() async {
    await _client.rpc('delete_own_account');
    await _client.auth.signOut();
  }
}
