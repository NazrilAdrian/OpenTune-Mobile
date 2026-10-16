import 'package:flutter/material.dart';

const _purple = Color(0xFF7C3AED);
const _background = Color(0xFF0F0F1A);
const _panel = Color(0xFF1A1A2E);

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedTab = 0;
  int _managementTab = 0;

  final List<Map<String, String>> _songs = [
    {
      'title': 'Midnight City',
      'artist': 'M83',
      'album': 'Hurry Up, We’re Dreaming',
      'genre': 'Electronic'
    },
    {'title': 'Snooze', 'artist': 'SZA', 'album': 'SOS', 'genre': 'R&B'},
    {
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'album': 'After Hours',
      'genre': 'Pop'
    },
  ];

  final List<Map<String, String>> _albums = [
    {'name': 'After Hours', 'artist': 'The Weeknd', 'year': '2020'},
    {'name': 'SOS', 'artist': 'SZA', 'year': '2022'},
    {'name': 'Hurry Up, We’re Dreaming', 'artist': 'M83', 'year': '2011'},
  ];

  final List<Map<String, String>> _artists = [
    {'name': 'The Weeknd', 'genre': 'Pop / R&B', 'country': 'Canada'},
    {'name': 'SZA', 'genre': 'R&B', 'country': 'United States'},
    {'name': 'M83', 'genre': 'Electronic', 'country': 'France'},
  ];

  final List<Map<String, String>> _genres = [
    {'name': 'Pop', 'description': 'Musik populer'},
    {'name': 'R&B', 'description': 'Rhythm and blues'},
    {'name': 'Electronic', 'description': 'Musik elektronik'},
  ];

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Alya Putri',
      'email': 'alya@email.com',
      'role': 'User',
      'banned': false
    },
    {
      'name': 'Raka Pratama',
      'email': 'raka@email.com',
      'role': 'User',
      'banned': false
    },
    {
      'name': 'Nazla Admin',
      'email': 'nazla@admin.com',
      'role': 'Admin',
      'banned': false
    },
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _editRecord({
    required String title,
    required List<String> fields,
    required List<String> initialValues,
    required void Function(List<String>) onSave,
  }) async {
    final controllers = List.generate(
      fields.length,
      (index) => TextEditingController(
        text: index < initialValues.length ? initialValues[index] : '',
      ),
    );
    final formKey = GlobalKey<FormState>();

    final values = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _panel,
        title: Text(
          title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < fields.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TextFormField(
                      controller: controllers[index],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: fields[index],
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: _background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '${fields[index]} wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _purple),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                  dialogContext,
                  controllers
                      .map((controller) => controller.text.trim())
                      .toList(),
                );
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

    if (values != null && mounted) {
      onSave(values);
      setState(() {});
      _showMessage('Perubahan berhasil disimpan sementara.');
    }
  }

  void _confirmDelete(String label, VoidCallback onDelete) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('Hapus data?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Data $label akan dihapus dari tampilan ini.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDelete();
              setState(() {});
              _showMessage('Data berhasil dihapus dari daftar sementara.');
            },
            child:
                const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pageTitles = [
      'Dashboard',
      'Song Management',
      'Album Management',
      'Artist Management',
      'Management',
    ];

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.headphones_rounded,
                  color: Color(0xFFA78BFA)),
            ),
            const SizedBox(width: 10),
            const Text('OpenTune',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Color(0xFFC4B5FD),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pageTitles[_selectedTab],
                          style: const TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Kelola ekosistem musik OpenTune',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedTab == 4) _managementSelector(),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _dashboard(),
                  _recordList(kind: 'song'),
                  _recordList(kind: 'album'),
                  _recordList(kind: 'artist'),
                  _managementPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF171727),
        indicatorColor: _purple.withValues(alpha: 0.25),
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.music_note_rounded), label: 'Songs'),
          NavigationDestination(
              icon: Icon(Icons.album_rounded), label: 'Albums'),
          NavigationDestination(icon: Icon(Icons.mic_rounded), label: 'Artis'),
          NavigationDestination(
              icon: Icon(Icons.tune_rounded), label: 'Lainnya'),
        ],
      ),
    );
  }

  Widget _managementSelector() {
    return PopupMenuButton<int>(
      initialValue: _managementTab,
      color: _panel,
      onSelected: (value) => setState(() => _managementTab = value),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 0, child: Text('Genre Management')),
        PopupMenuItem(value: 1, child: Text('User Management')),
      ],
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(_managementTab == 0 ? 'Genre' : 'Users'),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }

  Widget _dashboard() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient:
                const LinearGradient(colors: [_purple, Color(0xFF4C1D95)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat datang, Admin',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.shield_outlined),
                  SizedBox(width: 8),
                  Text('Admin workspace',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _statCard('Total Lagu', _songs.length.toString(), Icons.music_note,
                const Color(0xFFA78BFA)),
            _statCard('Total Album', _albums.length.toString(), Icons.album,
                const Color(0xFF60A5FA)),
            _statCard('Total Artis', _artists.length.toString(), Icons.mic,
                const Color(0xFFFBBF24)),
            _statCard('Total Genre', _genres.length.toString(), Icons.category,
                const Color(0xFF34D399)),
            _statCard('Total User', _users.length.toString(), Icons.people,
                const Color(0xFFF472B6)),
            _statCard(
              'User Banned',
              _users.where((user) => user['banned'] == true).length.toString(),
              Icons.block,
              const Color(0xFFF87171),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Akses cepat',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        for (final item in [
          (Icons.music_note, 'Kelola lagu', 1),
          (Icons.album, 'Kelola album', 2),
          (Icons.mic, 'Kelola artis', 3),
          (Icons.settings, 'Genre & pengguna', 4),
        ])
          Card(
            color: _panel,
            child: ListTile(
              leading: Icon(item.$1, color: const Color(0xFFA78BFA)),
              title: Text(item.$2),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => setState(() => _selectedTab = item.$3),
            ),
          ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Text(value,
              style:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _recordList({required String kind}) {
    final List<Map<String, String>> records = kind == 'song'
        ? _songs
        : kind == 'album'
            ? _albums
            : _artists;
    final titleKey = kind == 'song' ? 'title' : 'name';
    final title = kind == 'song'
        ? 'Lagu'
        : kind == 'album'
            ? 'Album'
            : 'Artis';
    final fields = kind == 'song'
        ? ['Judul lagu', 'Artis', 'Album', 'Genre']
        : kind == 'album'
            ? ['Nama album', 'Artis', 'Tahun rilis']
            : ['Nama artis', 'Genre', 'Negara'];
    final keys = kind == 'song'
        ? ['title', 'artist', 'album', 'genre']
        : kind == 'album'
            ? ['name', 'artist', 'year']
            : ['name', 'genre', 'country'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${records.length} ${title.toLowerCase()} terdaftar',
                style: const TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _editRecord(
                title: 'Tambah $title',
                fields: fields,
                initialValues: const [],
                onSave: (values) {
                  records.add({
                    for (var i = 0; i < keys.length; i++) keys[i]: values[i]
                  });
                },
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _purple, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Belum ada data.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
          ),
        for (var index = 0; index < records.length; index++)
          Card(
            color: _panel,
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _purple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          kind == 'song'
                              ? Icons.music_note
                              : kind == 'album'
                                  ? Icons.album
                                  : Icons.mic,
                          color: const Color(0xFFC4B5FD),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              records[index][titleKey] ?? '-',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              records[index][keys[1]] ?? '',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final record = records[index];
                            _editRecord(
                              title: 'Edit $title',
                              fields: fields,
                              initialValues: [
                                for (final key in keys) record[key] ?? ''
                              ],
                              onSave: (values) {
                                for (var i = 0; i < keys.length; i++) {
                                  record[keys[i]] = values[i];
                                }
                              },
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDelete(
                            title.toLowerCase(),
                            () => records.removeAt(index),
                          ),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Hapus'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF87171),
                            side: const BorderSide(color: Color(0x66F87171)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _managementPage() => _managementTab == 0 ? _genrePage() : _userPage();

  Widget _genrePage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${_genres.length} genre terdaftar',
                style: const TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _editRecord(
                title: 'Tambah Genre',
                fields: const ['Nama genre', 'Deskripsi'],
                initialValues: const [],
                onSave: (values) => _genres.add({
                  'name': values[0],
                  'description': values[1],
                }),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
              style: ElevatedButton.styleFrom(backgroundColor: _purple),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < _genres.length; index++)
          Card(
            color: _panel,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0x337C3AED),
                child: Icon(Icons.category, color: Color(0xFFC4B5FD)),
              ),
              title: Text(_genres[index]['name']!),
              subtitle: Text(
                _genres[index]['description']!,
                style: const TextStyle(color: Colors.white60),
              ),
              trailing: PopupMenuButton<String>(
                color: _panel,
                onSelected: (action) {
                  if (action == 'edit') {
                    final genre = _genres[index];
                    _editRecord(
                      title: 'Edit Genre',
                      fields: const ['Nama genre', 'Deskripsi'],
                      initialValues: [genre['name']!, genre['description']!],
                      onSave: (values) {
                        genre['name'] = values[0];
                        genre['description'] = values[1];
                      },
                    );
                  } else {
                    _confirmDelete('genre', () => _genres.removeAt(index));
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _userPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        Text(
          '${_users.length} pengguna terdaftar',
          style: const TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < _users.length; index++)
          Card(
            color: _panel,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _purple.withValues(alpha: 0.25),
                        child: Text(
                          (_users[index]['name'] as String)[0],
                          style: const TextStyle(color: Color(0xFFC4B5FD)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _users[index]['name'] as String,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _users[index]['email'] as String,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12),
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 6,
                              children: [
                                Chip(
                                  label: Text(
                                    _users[index]['role'] as String,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor:
                                      _purple.withValues(alpha: 0.2),
                                ),
                                if (_users[index]['banned'] == true)
                                  const Chip(
                                    label: Text('BANNED',
                                        style: TextStyle(fontSize: 10)),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: Color(0x44F87171),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final user = _users[index];
                            _editRecord(
                              title: 'Edit Pengguna',
                              fields: const ['Nama', 'Email'],
                              initialValues: [
                                user['name'] as String,
                                user['email'] as String,
                              ],
                              onSave: (values) {
                                user['name'] = values[0];
                                user['email'] = values[1];
                              },
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _users[index]['banned'] =
                                  !(_users[index]['banned'] as bool);
                            });
                            _showMessage(
                              (_users[index]['banned'] as bool)
                                  ? 'Pengguna dibanned.'
                                  : 'Ban pengguna dibuka.',
                            );
                          },
                          icon: Icon(
                            (_users[index]['banned'] as bool)
                                ? Icons.lock_open
                                : Icons.block,
                            size: 16,
                          ),
                          label: Text(
                            (_users[index]['banned'] as bool) ? 'Unban' : 'Ban',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFBBF24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        color: _panel,
                        tooltip: 'Aksi pengguna',
                        onSelected: (action) {
                          if (action == 'role') {
                            final user = _users[index];
                            var selectedRole = user['role'] as String;
                            showDialog<void>(
                              context: context,
                              builder: (dialogContext) => StatefulBuilder(
                                builder: (context, setDialogState) =>
                                    AlertDialog(
                                  backgroundColor: _panel,
                                  title: const Text('Ubah role'),
                                  content: DropdownButtonFormField<String>(
                                    initialValue: selectedRole,
                                    dropdownColor: _panel,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'User', child: Text('User')),
                                      DropdownMenuItem(
                                          value: 'Admin', child: Text('Admin')),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setDialogState(
                                            () => selectedRole = value);
                                      }
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        user['role'] = selectedRole;
                                        Navigator.pop(dialogContext);
                                        setState(() {});
                                      },
                                      child: const Text('Simpan'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            _confirmDelete(
                                'pengguna', () => _users.removeAt(index));
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'role', child: Text('Ubah role')),
                          PopupMenuItem(
                              value: 'delete', child: Text('Hapus pengguna')),
                        ],
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.more_vert),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
