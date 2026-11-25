import '../../../core/network/supabase_config.dart';

String requireUserId([String? expectedUserId]) {
  final userId = SupabaseConfig.client.auth.currentUser?.id;
  if (userId == null) throw StateError('Login diperlukan untuk operasi ini.');
  if (expectedUserId != null && userId != expectedUserId) {
    throw StateError('Akun aktif tidak sesuai dengan pemilik data.');
  }
  return userId;
}

Map<String, dynamic> allowedChanges(
  Map<String, dynamic> data,
  Set<String> allowedFields,
  String entity,
) {
  final invalidFields = data.keys.toSet().difference(allowedFields);
  if (invalidFields.isNotEmpty) {
    throw ArgumentError(
        'Kolom tidak dapat diubah pada $entity: ${invalidFields.join(', ')}.');
  }
  if (data.isEmpty) throw ArgumentError('Tidak ada perubahan untuk $entity.');
  return Map<String, dynamic>.from(data);
}

String escapeIlike(String value) => value
    .replaceAll('\\', '\\\\')
    .replaceAll('%', '\\%')
    .replaceAll('_', '\\_');
