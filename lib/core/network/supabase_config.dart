import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://jxglsxjwrhiugtxmvaxa.supabase.co/rest/v1/';
  static const String supabaseAnonKey = 'sb_publishable_lGELhawACEEH4_e0xbJ_xA_GXy7v60R';

  static SupabaseClient get client => Supabase.instance.client;
}
