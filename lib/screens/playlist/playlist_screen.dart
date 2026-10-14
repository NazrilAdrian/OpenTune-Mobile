import 'package:flutter/material.dart';

/// Palet warna disamakan dengan halaman Home (OpenTune).
/// Kalau kamu sudah punya file tema/konstanta warna, pindahkan ke sana.
class _AppColors {
  static const background = Color(0xFFF8F8FC);
  static const surface = Colors.white;
  static const primary = Color(0xFF7C4DFF);
  static const primaryLight = Color(0xFFEDE7FF);
  static const textPrimary = Color(0xFF1B1B2F);
  static const textSecondary = Color(0xFF8E8EA0);
  static const border = Color(0xFFECECF4);
}

class _PlaylistItem {
  final String name;
  final int songCount;
  final IconData icon;
  final List<Color> colors;

  const _PlaylistItem({
    required this.name,
    required this.songCount,
    required this.icon,
    required this.colors,
  });
}

/// Gaya cover yang dipakai bergantian untuk playlist baru.
class _CoverStyle {
  final IconData icon;
  final List<Color> colors;

  const _CoverStyle(this.icon, this.colors);
}

const _coverStyles = <_CoverStyle>[
  _CoverStyle(Icons.spa_rounded, [Color(0xFF7C4DFF), Color(0xFFB39DFF)]),
  _CoverStyle(Icons.nightlight_round, [Color(0xFF3F3D9E), Color(0xFF7C4DFF)]),
  _CoverStyle(
    Icons.fitness_center_rounded,
    [Color(0xFFFF7A59), Color(0xFFFFB38A)],
  ),
  _CoverStyle(Icons.headphones_rounded, [Color(0xFF3AA6B9), Color(0xFF8ADBE6)]),
  _CoverStyle(Icons.album_rounded, [Color(0xFFE056A0), Color(0xFFFFA1CF)]),
  _CoverStyle(Icons.piano_rounded, [Color(0xFF5C6BC0), Color(0xFF9FA8DA)]),
];

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final _filters = const ['Semua', 'Buatanku', 'Favorit', 'Diunduh'];
  int _selectedFilter = 0;

  /// Awalnya kosong, pengguna yang menambahkan sendiri.
  final List<_PlaylistItem> _playlists = [];
  int _createdCount = 0;
  String _query = '';

  List<_PlaylistItem> get _visiblePlaylists {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _playlists;
    return _playlists.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _showCreateDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _CreatePlaylistDialog(
        existingNames: _playlists.map((p) => p.name).toList(),
      ),
    );

    // Batal (null) -> kembali ke halaman seperti semula.
    if (name == null || !mounted) return;

    final style = _coverStyles[_createdCount % _coverStyles.length];
    setState(() {
      _createdCount++;
      _playlists.insert(
        0,
        _PlaylistItem(
          name: name,
          songCount: 0,
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
          backgroundColor: _AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text('Playlist "$name" berhasil dibuat'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final hasPlaylists = _playlists.isNotEmpty;
    final visible = _visiblePlaylists;

    return Scaffold(
      backgroundColor: _AppColors.background,
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
                      (context, index) => _PlaylistCard(item: visible[index]),
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
                    color: _AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_playlists.length} playlist • $totalSongs lagu',
                  style: const TextStyle(
                    color: _AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: _AppColors.primary,
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
          color: _AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _AppColors.border),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _query = value),
          style: const TextStyle(color: _AppColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Cari playlist...',
            hintStyle: TextStyle(color: _AppColors.textSecondary),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _AppColors.textSecondary,
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
                  color: selected ? _AppColors.primary : _AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? _AppColors.primary : _AppColors.border,
                  ),
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    color: selected ? Colors.white : _AppColors.textSecondary,
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
              color: _AppColors.primary.withAlpha(70),
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
                    color: _AppColors.primary,
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
              color: _AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.queue_music_rounded,
              size: 46,
              color: _AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada playlist',
            style: TextStyle(
              color: _AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Buat playlist pertamamu dan kumpulkan lagu favoritmu di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _AppColors.textSecondary,
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
              backgroundColor: _AppColors.primary,
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
                color: _AppColors.textPrimary,
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
                Icon(Icons.sort_rounded, size: 18, color: _AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'Urutkan',
                  style: TextStyle(
                    color: _AppColors.primary,
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
          style: TextStyle(color: _AppColors.textSecondary, fontSize: 14),
        ),
      ),
    );
  }
}

/// Dialog input nama playlist. Mengembalikan nama (String) jika "Buat",
/// atau null jika "Batal".
class _CreatePlaylistDialog extends StatefulWidget {
  final List<String> existingNames;

  const _CreatePlaylistDialog({required this.existingNames});

  @override
  State<_CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<_CreatePlaylistDialog> {
  final _controller = TextEditingController();

  String get _name => _controller.text.trim();

  bool get _isDuplicate => widget.existingNames
      .any((n) => n.trim().toLowerCase() == _name.toLowerCase());

  bool get _canSubmit => _name.isNotEmpty && !_isDuplicate;

  void _submit() {
    if (!_canSubmit) return;
    Navigator.of(context).pop(_name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      title: const Text(
        'Playlist Baru',
        style: TextStyle(
          color: _AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Beri nama untuk playlist kamu.',
            style: TextStyle(color: _AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 30,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
            style: const TextStyle(color: _AppColors.textPrimary, fontSize: 15),
            cursorColor: _AppColors.primary,
            decoration: InputDecoration(
              hintText: 'Nama playlist',
              hintStyle: const TextStyle(color: _AppColors.textSecondary),
              errorText: _isDuplicate && _name.isNotEmpty
                  ? 'Nama playlist sudah digunakan'
                  : null,
              counterText: '',
              filled: true,
              fillColor: _AppColors.background,
              prefixIcon: const Icon(
                Icons.queue_music_rounded,
                color: _AppColors.primary,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: _AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: _AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Batal',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: _canSubmit ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _AppColors.primaryLight,
            disabledForegroundColor: _AppColors.textSecondary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Buat',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final _PlaylistItem item;

  const _PlaylistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // TODO: buka detail playlist
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _AppColors.primary.withAlpha(18),
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
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: _AppColors.primary,
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
                  color: _AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.songCount} lagu',
                style: const TextStyle(
                  color: _AppColors.textSecondary,
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
