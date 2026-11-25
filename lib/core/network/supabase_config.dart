import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://jxglsxjwrhiugtxmvaxa.supabase.co';
<<<<<<< HEAD
  static const String supabaseAnonKey =
      'sb_publishable_lGELhawACEEH4_e0xbJ_xA_GXy7v60R';
=======
  static const String supabaseAnonKey = 'sb_publishable_lGELhawACEEH4_e0xbJ_xA_GXy7v60R';
>>>>>>> origin/Nazril

  static SupabaseClient get client => Supabase.instance.client;
}
