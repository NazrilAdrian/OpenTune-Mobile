import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException;
import 'package:flutter/foundation.dart' show debugPrint;

import '../../../core/network/supabase_config.dart';
import '../models/artist_model.dart';
import 'repository_guard.dart';

class ArtistRepository {
  Future<ArtistModel?> findArtistByName(String name) async {
    final normalizedName = _normalizeName(name);
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Nama artis wajib diisi.');
    }
    final rows = await SupabaseConfig.client
        .from('artists')
        .select()
        .ilike('name', escapeIlike(normalizedName))
        .order('artist_id', ascending: true);
    if (rows.length > 1) {
      debugPrint(
        'Duplikasi artist "$normalizedName" ditemukan pada ID '
        '${rows.map((row) => row['artist_id']).join(', ')}; memakai ID terkecil.',
      );
    }
    return rows.isEmpty ? null : ArtistModel.fromJson(rows.first);
  }

  Future<ArtistModel> findOrCreateArtist(String name) async {
    final normalizedName = _normalizeName(name);
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Nama artis wajib diisi.');
    }
    final existing = await findArtistByName(normalizedName);
    if (existing != null) return existing;
    requireUserId();
    try {
      final row = await SupabaseConfig.client
          .from('artists')
          .insert({'name': normalizedName})
          .select()
          .single();
      return ArtistModel.fromJson(row);
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        final concurrentArtist = await findArtistByName(normalizedName);
        if (concurrentArtist != null) return concurrentArtist;
      }
      rethrow;
    }
  }

  String _normalizeName(String name) => name.trim().replaceAll(RegExp(r'\s+'), ' ');
}
