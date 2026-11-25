import 'package:flutter/material.dart';

import 'playlist_model.dart';
import 'playlist_name_dialog.dart';

/// Halaman isi playlist (tampilan seperti Spotify, dengan warna tema OpenTune).
class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  /// Nama playlist lain, dipakai untuk mencegah nama ganda saat rename.
  final List<String> otherNames;

  /// Dipanggil setelah nama berhasil diubah.
  final ValueChanged<String> onRename;

  /// Dipanggil setelah pengguna mengonfirmasi hapus. Halaman ini akan
  /// menutup dirinya sendiri setelahnya.
  final VoidCallback onDelete;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.otherNames,
    required this.onRename,
    required this.onDelete,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  Playlist get _playlist => widget.playlist;

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text('$feature segera hadir'),
        ),
      );
  }

  Future<void> _rename() async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => PlaylistNameDialog(
        title: 'Ubah Nama Playlist',
        description: 'Masukkan nama baru untuk playlist ini.',
        confirmLabel: 'Simpan',
        initialName: _playlist.name,
        existingNames: widget.otherNames,
      ),
    );

    if (newName == null || !mounted) return;
    widget.onRename(newName);
    setState(() {});

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text('Nama playlist diperbarui'),
        ),
      );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Hapus playlist?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Playlist "${_playlist.name}" akan dihapus dan tidak bisa '
          'dikembalikan.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text(
              'Batal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    widget.onDelete();
    Navigator.of(context).pop();
  }

  void _showMoreSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.textPrimary,
                ),
                title: const Text('Ubah nama playlist'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _rename();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
                title: const Text(
                  'Hapus playlist',
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _confirmDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final songs = _playlist.songs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Latar gradasi dari warna cover, memudar ke warna background
          // (seperti header merah di referensi).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 440,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _playlist.colors.first.withAlpha(200),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar()),
                SliverToBoxAdapter(child: _buildCover()),
                SliverToBoxAdapter(child: _buildTitleSection()),
                SliverToBoxAdapter(child: _buildActionRow()),
                SliverToBoxAdapter(child: _buildChips()),
                if (songs.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptySongs())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _SongTile(
                        song: songs[index],
                        colors: _playlist.colors,
                        icon: _playlist.icon,
                      ),
                      childCount: songs.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
            tooltip: 'Kembali',
          ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Hero(
          tag: 'playlist-cover-${_playlist.id}',
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _playlist.colors,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              _playlist.icon,
              size: 84,
              color: Colors.white.withAlpha(220),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _playlist.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'K',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // TODO: ganti dengan nama pengguna yang sedang login.
              const Text(
                'Kamu',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.public_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${_playlist.songCount} lagu',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _comingSoon('Unduh'),
            icon: const Icon(Icons.download_for_offline_outlined),
            iconSize: 28,
            color: AppColors.textSecondary,
            tooltip: 'Unduh',
          ),
          IconButton(
            onPressed: () => _comingSoon('Bagikan'),
            icon: const Icon(Icons.share_outlined),
            iconSize: 26,
            color: AppColors.textSecondary,
            tooltip: 'Bagikan',
          ),
          IconButton(
            onPressed: _showMoreSheet,
            icon: const Icon(Icons.more_vert_rounded),
            iconSize: 26,
            color: AppColors.textSecondary,
            tooltip: 'Opsi lainnya',
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _comingSoon('Acak'),
            icon: const Icon(Icons.shuffle_rounded),
            iconSize: 28,
            color: AppColors.primary,
            tooltip: 'Acak',
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                // TODO: putar playlist
                if (_playlist.songs.isEmpty) _comingSoon('Putar playlist');
              },
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
        height: 42,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _ActionChip(
              icon: Icons.add_rounded,
              label: 'Tambahkan',
              onTap: () {
                // TODO: tambah lagu ke playlist
                _comingSoon('Tambah lagu');
              },
            ),
            const SizedBox(width: 10),
            _ActionChip(
              icon: Icons.edit_outlined,
              label: 'Nama & detail',
              onTap: _rename,
            ),
            const SizedBox(width: 10),
            _ActionChip(
              icon: Icons.delete_outline_rounded,
              label: 'Hapus',
              color: AppColors.danger,
              onTap: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySongs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.music_note_rounded,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Playlist ini masih kosong',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tekan "Tambahkan" untuk mengisi playlist dengan lagu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final Song song;
  final List<Color> colors;
  final IconData icon;

  const _SongTile({
    required this.song,
    required this.colors,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(colors: colors),
        ),
        child: Icon(icon, color: Colors.white.withAlpha(220), size: 24),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      trailing: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: () {
        // TODO: putar lagu
      },
    );
  }
}
