import 'package:flutter/material.dart';

import 'playlist_detail_screen.dart';
import 'playlist_model.dart';
import 'playlist_name_dialog.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final _filters = const ['Semua', 'Buatanku', 'Favorit', 'Diunduh'];
  int _selectedFilter = 0;

  /// Awalnya kosong, pengguna yang menambahkan sendiri.
  final List<Playlist> _playlists = [];
  int _createdCount = 0;
  String _query = '';

  List<Playlist> get _visiblePlaylists {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _playlists;
    return _playlists.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _showCreateDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => PlaylistNameDialog(
        existingNames: _playlists.map((p) => p.name).toList(),
      ),
    );

    // Batal (null) -> kembali ke halaman seperti semula.
    if (name == null || !mounted) return;

    final style = coverStyles[_createdCount % coverStyles.length];
    setState(() {
      _createdCount++;
      _playlists.insert(
        0,
        Playlist(
          name: name,
          icon: style.icon,
          colors: style.colors,
        ),
      );
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text('Playlist "$name" berhasil dibuat'),
        ),
      );
  }

  void _openPlaylist(Playlist playlist) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlaylistDetailScreen(
          playlist: playlist,
          otherNames: _playlists
              .where((p) => p.id != playlist.id)
              .map((p) => p.name)
              .toList(),
          onRename: (newName) => setState(() => playlist.name = newName),
          onDelete: () {
            final name = playlist.name;
            setState(() => _playlists.removeWhere((p) => p.id == playlist.id));
            _showMessage('Playlist "$name" dihapus');
          },
        ),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final hasPlaylists = _playlists.isNotEmpty;
    final visible = _visiblePlaylists;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            if (hasPlaylists) ...[
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildFilterChips()),
            ],
            SliverToBoxAdapter(child: _buildLikedSongsCard()),
            if (!hasPlaylists)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else ...[
              SliverToBoxAdapter(child: _buildSectionHeader()),
              if (visible.isEmpty)
                const SliverToBoxAdapter(child: _NoResult())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _PlaylistCard(
                        item: visible[index],
                        onTap: () => _openPlaylist(visible[index]),
                      ),
                      childCount: visible.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final totalSongs = _playlists.fold<int>(0, (sum, p) => sum + p.songCount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Playlist',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_playlists.length} playlist • $totalSongs lagu',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _showCreateDialog,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _query = value),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Cari playlist...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final selected = index == _selectedFilter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLikedSongsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6B3DF2), Color(0xFF9F7BFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(70),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lagu Disukai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '0 lagu',
                    style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  // TODO: putar Lagu Disukai
                },
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.queue_music_rounded,
              size: 46,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada playlist',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Buat playlist pertamamu dan kumpulkan lagu favoritmu di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Buat Playlist'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Playlist Kamu',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: opsi urutkan
            },
            child: const Row(
              children: [
                Icon(Icons.sort_rounded, size: 18, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'Urutkan',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResult extends StatelessWidget {
  const _NoResult();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Center(
        child: Text(
          'Playlist tidak ditemukan',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final Playlist item;
  final VoidCallback onTap;

  const _PlaylistCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: 'playlist-cover-${item.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: item.colors,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 44,
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.songCount} lagu',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
