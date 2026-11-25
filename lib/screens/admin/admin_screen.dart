import 'package:flutter/material.dart';
import '../../widgets/opentune_ui.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;
  int _catalogTab = 0;
  String _query = '';
  String _adminName = 'Nazla Admin';
  String _adminUsername = 'nazla_admin';
  String _adminEmail = 'nazla@admin.com';
  String _adminPhone = '';

  final List<Map<String, dynamic>> _users = [
    {'name': 'Alya Putri', 'email': 'alya@email.com', 'role': 'User', 'active': true},
    {'name': 'Raka Pratama', 'email': 'raka@email.com', 'role': 'User', 'active': true},
    {'name': 'Nazla Admin', 'email': 'nazla@admin.com', 'role': 'Admin', 'active': true},
  ];

  final List<Map<String, String>> _songs = [
    {'title': 'Setsunarensa', 'artist': 'Radwimps', 'album': 'Your Name', 'genre': 'Pop'},
    {'title': 'Dramaturgy', 'artist': 'Eve', 'album': '文化', 'genre': 'Rock'},
    {'title': 'Starlight Parade', 'artist': 'Sekai No Owari', 'album': 'Tree', 'genre': 'Pop'},
    {'title': 'Saikai', 'artist': 'Vaundy', 'album': 'Replica', 'genre': 'Indie'},
  ];

  final List<Map<String, String>> _albums = [
    {'name': 'Your Name', 'artist': 'Radwimps', 'year': '2016'},
    {'name': '文化', 'artist': 'Eve', 'year': '2020'},
    {'name': 'Tree', 'artist': 'Sekai No Owari', 'year': '2015'},
  ];

  final List<Map<String, String>> _artists = [
    {'name': 'Radwimps', 'genre': 'Rock', 'country': 'Jepang'},
    {'name': 'Eve', 'genre': 'Rock / Pop', 'country': 'Jepang'},
    {'name': 'Vaundy', 'genre': 'Pop', 'country': 'Jepang'},
  ];

  final List<Map<String, String>> _genres = [
    {'name': 'Pop', 'description': 'Musik populer'},
    {'name': 'Rock', 'description': 'Musik dengan karakter gitar kuat'},
    {'name': 'Indie', 'description': 'Musik independen'},
    {'name': 'R&B', 'description': 'Rhythm and blues'},
  ];

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: OpenTuneColors.purple,
        ),
      );

  Future<void> _form({
    required String title,
    required List<String> labels,
    required List<String> initial,
    required ValueChanged<List<String>> onSave,
  }) async {
    final controllers = List.generate(
      labels.length,
      (i) => TextEditingController(text: i < initial.length ? initial[i] : ''),
    );
    final key = GlobalKey<FormState>();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: OpenTuneColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Form(
          key: key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < labels.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: controllers[i],
                      decoration: InputDecoration(
                        labelText: labels[i],
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: OpenTuneColors.purple),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? '${labels[i]} wajib diisi'
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: OpenTuneColors.purple),
            onPressed: () {
              if (key.currentState!.validate()) {
                Navigator.pop(ctx, controllers.map((c) => c.text.trim()).toList());
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    for (final controller in controllers) {
      controller.dispose();
    }
    if (result != null && mounted) {
      onSave(result);
      setState(() {});
      _message('Perubahan disimpan sementara.');
    }
  }

  void _delete(String label, VoidCallback action) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi hapus'),
        content: Text('Yakin ingin menghapus $label dari daftar contoh?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              action();
              setState(() {});
              _message('Data dihapus dari simulasi.');
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openProfile() {
    setState(() {
      _tab = 4;
      _query = '';
    });
  }

  void _selectTab(int index) {
    if (index == 4) {
      _openProfile();
      return;
    }
    setState(() {
      _tab = index;
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Dashboard Admin',
      'Manajemen Pengguna',
      'Katalog Musik',
      'Manajemen Genre',
      'Profil Admin',
    ];
    final pageTitle = titles[_tab];

    return Scaffold(
      backgroundColor: OpenTuneColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: OpenTuneColors.text),
          onPressed: () => Navigator.maybePop(context),
          tooltip: 'Kembali',
        ),    
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_opentune.png',
              width: 39,
              height: 39,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 9),
            const Expanded(
              child: Text(
                'OpenTune',
                style: TextStyle(
                  color: OpenTuneColors.purple,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: OpenTuneColors.purplePale,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: OpenTuneColors.purple,
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pageTitle,
                    style: const TextStyle(
                      color: OpenTuneColors.text,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kelola pengguna dan katalog musik OpenTune',
                    style: TextStyle(color: OpenTuneColors.muted, fontSize: 12),
                  ),
                  if (_tab != 0) ...[
                    const SizedBox(height: 14),
                    TextField(
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: OpenTuneColors.purple,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: _tab == 2
                            ? 'Cari lagu, album, atau artis...'
                            : 'Cari data...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: OpenTuneColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: OpenTuneColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: OpenTuneColors.purple,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _dashboard(),
                  _userPage(),
                  _catalogPage(),
                  _genrePage(),
                  _profilePage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: OpenTuneColors.purplePale,

          iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: OpenTuneColors.purple,
                );
              }
              return const IconThemeData(
                color: Colors.grey,
              );
            },
          ),

          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: OpenTuneColors.purple,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                );
              }
              return const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              );
            },
          ),
        ),

        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Pengguna',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_music_outlined),
              selectedIcon: Icon(Icons.library_music),
              label: 'Katalog',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category),
              label: 'Genre',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              selectedIcon: Icon(Icons.account_circle),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboard() => ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [OpenTuneColors.purple, Color(0xFF8B6CFA)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 30),
                SizedBox(height: 12),
                Text(
                  'Selamat datang, Admin!',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 5),
                Text(
                  'Pantau dan kelola konten OpenTune di satu tempat.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _stat('Total Pengguna', '${_users.length}', Icons.people_alt_outlined),
              _stat('Total Lagu', '${_songs.length}', Icons.music_note_rounded),
              _stat('Total Album', '${_albums.length}', Icons.album_outlined),
              _stat('Total Artis', '${_artists.length}', Icons.mic_none_rounded),
              _stat('Total Genre', '${_genres.length}', Icons.category_rounded),
              _stat('Pengguna Nonaktif', '${_users.where((u) => u['active'] != true).length}', Icons.person_off_outlined),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Akses cepat',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: OpenTuneColors.text),
          ),
          const SizedBox(height: 10),
          _quick(Icons.people_outline, 'Kelola pengguna', 'Lihat role dan status akun', () => _selectTab(1)),
          _quick(Icons.library_music_outlined, 'Kelola katalog', 'Lagu, album, dan artis', () => _selectTab(2)),
          _quick(Icons.category_outlined, 'Kelola genre', 'Tambah, ubah, atau hapus genre', () => _selectTab(3)),
          const SizedBox(height: 8),
          const Text(
            'Data pada halaman ini adalah data dummy untuk simulasi UI/UX.',
            style: TextStyle(color: OpenTuneColors.muted, fontSize: 12),
          ),
        ],
      );

  Widget _stat(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: OpenTuneColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: OpenTuneColors.purple, size: 23),
            Text(
              value,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: OpenTuneColors.text),
            ),
            Text(label, style: const TextStyle(fontSize: 11, color: OpenTuneColors.muted)),
          ],
        ),
      );

  Widget _quick(IconData icon, String title, String subtitle, VoidCallback onTap) => Card(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: OpenTuneColors.border),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: OpenTuneColors.purplePale,
            child: Icon(icon, color: OpenTuneColors.purple),
          ),
          title: Text(title, style: const TextStyle(color: OpenTuneColors.text, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: const TextStyle(color: OpenTuneColors.muted, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, color: OpenTuneColors.muted),
          onTap: onTap,
        ),
      );

  Widget _userPage() {
    final items = _users
        .where((u) => '${u['name']} ${u['email']} ${u['role']}'.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text('${items.length} pengguna ditampilkan', style: const TextStyle(color: OpenTuneColors.muted))),
            FilledButton.icon(
              onPressed: () => _form(
                title: 'Tambah pengguna',
                labels: const ['Nama', 'Email', 'Role (User/Admin)'],
                initial: const [],
                onSave: (v) => _users.add({'name': v[0], 'email': v[1], 'role': v[2], 'active': true}),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final user in items)
          _itemCard(
            icon: Icons.person_outline,
            title: user['name'] as String,
            subtitle: '${user['email']}\nRole: ${user['role']}',
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _form(
                    title: 'Edit pengguna',
                    labels: const ['Nama', 'Email', 'Role (User/Admin)'],
                    initial: [user['name'] as String, user['email'] as String, user['role'] as String],
                    onSave: (v) { user['name'] = v[0]; user['email'] = v[1]; user['role'] = v[2]; },
                  );
                }
                if (value == 'status') setState(() => user['active'] = user['active'] != true);
                if (value == 'delete') _delete('pengguna ${user['name']}', () => _users.remove(user));
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit data')),
                PopupMenuItem(value: 'status', child: Text(user['active'] == true ? 'Nonaktifkan akun' : 'Aktifkan akun')),
                const PopupMenuItem(value: 'delete', child: Text('Hapus pengguna')),
              ],
            ),
            badge: user['active'] == true ? 'Aktif' : 'Nonaktif',
          ),
      ],
    );
  }

  Widget _catalogPage() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              label: Text('Lagu'),
              icon: Icon(Icons.music_note_outlined),
            ),
            ButtonSegment(
              value: 1,
              label: Text('Album'),
              icon: Icon(Icons.album_outlined),
            ),
            ButtonSegment(
              value: 2,
              label: Text('Artis'),
              icon: Icon(Icons.mic_none_rounded),
            ),
          ],
          selected: {_catalogTab},
          onSelectionChanged: (selection) =>
              setState(() => _catalogTab = selection.first),
          showSelectedIcon: false,

          // PENGATURAN WARNA SAJA
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return OpenTuneColors.purplePale;
                }
                return Colors.white;
              },
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return OpenTuneColors.purple;
                }
                return Colors.grey;
              },
            ),
            side: WidgetStateProperty.all(
              const BorderSide(color: Color(0xFFE5E5EA)),
            ),
          ),
        ),
      ),
      Expanded(
        child: IndexedStack(
          index: _catalogTab,
          children: [_songPage(), _albumPage(), _artistPage()],
        ),
      ),
    ],
  );

  Widget _songPage() {
    final items = _songs.where((s) => s.values.join(' ').toLowerCase().contains(_query.toLowerCase())).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      children: [
        _listHeader('${items.length} lagu ditampilkan', 'Tambah lagu', () => _form(
          title: 'Tambah lagu',
          labels: const ['Judul lagu', 'Artis', 'Album', 'Genre'],
          initial: const [],
          onSave: (v) => _songs.add({'title': v[0], 'artist': v[1], 'album': v[2], 'genre': v[3]}),
        )),
        const SizedBox(height: 12),
        for (final song in items)
          _itemCard(
            icon: Icons.music_note_rounded,
            title: song['title']!,
            subtitle: '${song['artist']} • ${song['album']}\nGenre: ${song['genre']}',
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _form(
                    title: 'Edit lagu',
                    labels: const ['Judul lagu', 'Artis', 'Album', 'Genre'],
                    initial: [song['title']!, song['artist']!, song['album']!, song['genre']!],
                    onSave: (v) { song['title'] = v[0]; song['artist'] = v[1]; song['album'] = v[2]; song['genre'] = v[3]; },
                  );
                }
                if (value == 'delete') _delete('lagu ${song['title']}', () => _songs.remove(song));
                if (value == 'detail') {
                  showDialog<void>(context: context, builder: (ctx) => AlertDialog(
                    title: Text(song['title']!),
                    content: Text('Artis: ${song['artist']}\nAlbum: ${song['album']}\nGenre: ${song['genre']}'),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
                  ));
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'detail', child: Text('Lihat detail')),
                PopupMenuItem(value: 'edit', child: Text('Edit metadata')),
                PopupMenuItem(value: 'delete', child: Text('Hapus lagu')),
              ],
            ),
            badge: song['genre']!,
          ),
      ],
    );
  }

  Widget _albumPage() {
    final items = _albums.where((a) => a.values.join(' ').toLowerCase().contains(_query.toLowerCase())).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      children: [
        _listHeader('${items.length} album ditampilkan', 'Tambah album', () => _form(
          title: 'Tambah album',
          labels: const ['Nama album', 'Artis', 'Tahun rilis'],
          initial: const [],
          onSave: (v) => _albums.add({'name': v[0], 'artist': v[1], 'year': v[2]}),
        )),
        const SizedBox(height: 12),
        for (final album in items)
          _itemCard(
            icon: Icons.album_outlined,
            title: album['name']!,
            subtitle: 'Artis: ${album['artist']}\nTahun rilis: ${album['year']}',
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _form(
                    title: 'Edit album',
                    labels: const ['Nama album', 'Artis', 'Tahun rilis'],
                    initial: [album['name']!, album['artist']!, album['year']!],
                    onSave: (v) { album['name'] = v[0]; album['artist'] = v[1]; album['year'] = v[2]; },
                  );
                }
                if (value == 'delete') _delete('album ${album['name']}', () => _albums.remove(album));
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit album')),
                PopupMenuItem(value: 'delete', child: Text('Hapus album')),
              ],
            ),
            badge: album['year']!,
          ),
      ],
    );
  }

  Widget _artistPage() {
    final items = _artists.where((a) => a.values.join(' ').toLowerCase().contains(_query.toLowerCase())).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      children: [
        _listHeader('${items.length} artis ditampilkan', 'Tambah artis', () => _form(
          title: 'Tambah artis',
          labels: const ['Nama artis', 'Genre', 'Negara'],
          initial: const [],
          onSave: (v) => _artists.add({'name': v[0], 'genre': v[1], 'country': v[2]}),
        )),
        const SizedBox(height: 12),
        for (final artist in items)
          _itemCard(
            icon: Icons.mic_none_rounded,
            title: artist['name']!,
            subtitle: 'Genre: ${artist['genre']}\nNegara: ${artist['country']}',
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _form(
                    title: 'Edit artis',
                    labels: const ['Nama artis', 'Genre', 'Negara'],
                    initial: [artist['name']!, artist['genre']!, artist['country']!],
                    onSave: (v) { artist['name'] = v[0]; artist['genre'] = v[1]; artist['country'] = v[2]; },
                  );
                }
                if (value == 'delete') _delete('artis ${artist['name']}', () => _artists.remove(artist));
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit artis')),
                PopupMenuItem(value: 'delete', child: Text('Hapus artis')),
              ],
            ),
            badge: artist['genre']!,
          ),
      ],
    );
  }

  Widget _genrePage() {
    final items = _genres.where((g) => '${g['name']} ${g['description']}'.toLowerCase().contains(_query.toLowerCase())).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      children: [
        _listHeader('${items.length} genre ditampilkan', 'Tambah genre', () => _form(
          title: 'Tambah genre',
          labels: const ['Nama genre', 'Deskripsi'],
          initial: const [],
          onSave: (v) => _genres.add({'name': v[0], 'description': v[1]}),
        )),
        const SizedBox(height: 12),
        for (final genre in items)
          _itemCard(
            icon: Icons.category_outlined,
            title: genre['name']!,
            subtitle: genre['description']!,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _form(
                    title: 'Edit genre',
                    labels: const ['Nama genre', 'Deskripsi'],
                    initial: [genre['name']!, genre['description']!],
                    onSave: (v) { genre['name'] = v[0]; genre['description'] = v[1]; },
                  );
                }
                if (value == 'delete') _delete('genre ${genre['name']}', () => _genres.remove(genre));
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit genre')),
                PopupMenuItem(value: 'delete', child: Text('Hapus genre')),
              ],
            ),
            badge: 'Genre',
          ),
      ],
    );
  }

  Widget _profilePage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
      children: [
        // HEADER PROFIL
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                OpenTuneColors.purple,
                Color(0xFF8B6CFA),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 46,
                  color: OpenTuneColors.purple,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nazla Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'nazla@admin.com',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SUPER ADMIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OpenTuneColors.purple,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _editAdminProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // INFORMASI PRIBADI
        _profileSection(
          title: 'Informasi Pribadi',
          subtitle: 'Informasi akun administrator',
          icon: Icons.person_outline,
          child: Column(
            children: [
              _profileInfo(
                Icons.badge_outlined,
                'Nama Lengkap',
                _adminName,
              ),
              _profileInfo(
                Icons.alternate_email,
                'Username',
                _adminUsername,
              ),
              _profileInfo(
                Icons.email_outlined,
                'Email',
                _adminEmail,
              ),
              _profileInfo(
                Icons.phone_outlined,
                'Nomor Telepon',
                _adminPhone.isEmpty ? 'Belum diisi' : _adminPhone,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // KEAMANAN AKUN
        _profileSection(
          title: 'Keamanan Akun',
          subtitle: 'Kelola keamanan administrator',
          icon: Icons.shield_outlined,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: OpenTuneColors.purplePale,
              child: Icon(
                Icons.lock_outline,
                color: OpenTuneColors.purple,
              ),
            ),
            title: const Text(
              'Password',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: OpenTuneColors.text,
              ),
            ),
            subtitle: const Text('Ubah password akun admin'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeAdminPassword,
          ),
        ),

        const SizedBox(height: 16),

        // AKTIVITAS AKUN
        _profileSection(
          title: 'Aktivitas Akun',
          subtitle: 'Informasi aktivitas administrator',
          icon: Icons.history,
          child: Column(
            children: [
              _profileInfo(
                Icons.circle,
                'Status Akun',
                'Aktif',
              ),
              _profileInfo(
                Icons.access_time,
                'Terakhir Login',
                'Belum tersedia',
              ),
              _profileInfo(
                Icons.calendar_today_outlined,
                'Tanggal Bergabung',
                'Belum tersedia',
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // LOGOUT
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Colors.redAccent),
          ),
          onPressed: _confirmAdminLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Keluar dari Akun'),
        ),

        const SizedBox(height: 12),
        const Center(
          child: Text(
            'OpenTune Admin Panel',
            style: TextStyle(
              color: OpenTuneColors.muted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OpenTuneColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: OpenTuneColors.purple),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: OpenTuneColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: OpenTuneColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          child,
        ],
      ),
    );
  }

  Widget _profileInfo(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: OpenTuneColors.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: OpenTuneColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: OpenTuneColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editAdminProfile() {
    _form(
      title: 'Edit Profil Admin',
      labels: const [
        'Nama Lengkap',
        'Username',
        'Email',
        'Nomor Telepon',
      ],
      initial: [
        _adminName,
        _adminUsername,
        _adminEmail,
        _adminPhone.isEmpty ? '-' : _adminPhone,
      ],
      onSave: (v) {
        setState(() {
          _adminName = v[0];
          _adminUsername = v[1];
          _adminEmail = v[2];
          _adminPhone = v[3] == '-' ? '' : v[3];
        });
      },
    );
  }

  void _changeAdminPassword() {
  final formKey = GlobalKey<FormState>();
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Ganti Password'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [              
              TextFormField(
                controller: currentController,
                obscureText: true,
                style: const TextStyle(
                  color: OpenTuneColors.text,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
                cursorColor: OpenTuneColors.purple,
                decoration: const InputDecoration(
                  labelText: 'Password Saat Ini',
                  labelStyle: TextStyle(
                    color: OpenTuneColors.muted,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: OpenTuneColors.purple,
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: OpenTuneColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: OpenTuneColors.purple,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty
                        ? 'Password saat ini wajib diisi'
                        : null,
              ),
            ]
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: OpenTuneColors.purple,
          ),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx);
              _message(
                'Form valid. Perubahan password belum disimpan ke server.',
              );
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  ).whenComplete(() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  });
}

  void _confirmAdminLogout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari halaman admin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _message(
                'Logout belum dihubungkan ke sistem autentikasi.',
              );
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _listHeader(String countLabel, String buttonLabel, VoidCallback onAdd) => Row(
        children: [
          Expanded(child: Text(countLabel, style: const TextStyle(color: OpenTuneColors.muted))),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: Text(buttonLabel),
          ),
        ],
      );

  Widget _itemCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required String badge,
  }) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OpenTuneColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: OpenTuneColors.purplePale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: OpenTuneColors.purple),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: OpenTuneColors.text, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: OpenTuneColors.muted, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: OpenTuneColors.purplePale,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(color: OpenTuneColors.purple, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      );
}
