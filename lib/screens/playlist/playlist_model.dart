import 'package:flutter/material.dart';

/// Palet warna disamakan dengan halaman Home (OpenTune).
/// Kalau kamu sudah punya file tema/konstanta warna, pindahkan ke sana.
class AppColors {
  static const background = Color(0xFFF8F8FC);
  static const surface = Colors.white;
  static const primary = Color(0xFF7C4DFF);
  static const primaryLight = Color(0xFFEDE7FF);
  static const textPrimary = Color(0xFF1B1B2F);
  static const textSecondary = Color(0xFF8E8EA0);
  static const border = Color(0xFFECECF4);
  static const danger = Color(0xFFE5484D);
}

class Song {
  final String title;
  final String artist;

  const Song({required this.title, required this.artist});
}

class Playlist {
  /// Id unik, dipakai juga sebagai tag animasi Hero.
  final String id;
  String name;
  final IconData icon;
  final List<Color> colors;
  final List<Song> songs;

  Playlist({
    required this.name,
    required this.icon,
    required this.colors,
    List<Song>? songs,
  })  : id = DateTime.now().microsecondsSinceEpoch.toString(),
        songs = songs ?? [];

  int get songCount => songs.length;
}

/// Gaya cover yang dipakai bergantian untuk playlist baru.
class CoverStyle {
  final IconData icon;
  final List<Color> colors;

  const CoverStyle(this.icon, this.colors);
}

const coverStyles = <CoverStyle>[
  CoverStyle(Icons.spa_rounded, [Color(0xFF7C4DFF), Color(0xFFB39DFF)]),
  CoverStyle(Icons.nightlight_round, [Color(0xFF3F3D9E), Color(0xFF7C4DFF)]),
  CoverStyle(
    Icons.fitness_center_rounded,
    [Color(0xFFFF7A59), Color(0xFFFFB38A)],
  ),
  CoverStyle(Icons.headphones_rounded, [Color(0xFF3AA6B9), Color(0xFF8ADBE6)]),
  CoverStyle(Icons.album_rounded, [Color(0xFFE056A0), Color(0xFFFFA1CF)]),
  CoverStyle(Icons.piano_rounded, [Color(0xFF5C6BC0), Color(0xFF9FA8DA)]),
];
