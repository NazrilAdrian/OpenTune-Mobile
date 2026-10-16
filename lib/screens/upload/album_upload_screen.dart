import 'package:flutter/material.dart';

import '../../widgets/opentune_ui.dart';

class AlbumUploadScreen extends StatefulWidget {
  const AlbumUploadScreen({super.key});

  @override
  State<AlbumUploadScreen> createState() => _AlbumUploadScreenState();
}

class _AlbumUploadScreenState extends State<AlbumUploadScreen> {
  String _genre = 'JPop';

  void _showWireframeMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: OpenTuneColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: OpenTuneColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: OpenTuneColors.purple,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenTuneColors.background,
      appBar: AppBar(
        backgroundColor: OpenTuneColors.background,
        foregroundColor: OpenTuneColors.text,
        elevation: 0,
        title: const Text(
          'OpenTune',
          style: TextStyle(
            color: OpenTuneColors.purple,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 26),
          children: [
            const Center(
              child: Text(
                'Upload Album',
                style: TextStyle(
                  color: OpenTuneColors.purple,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Unggah cover, isi informasi album, dan pilih berkas lagu sebagai bagian dari album.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: OpenTuneColors.muted,
                fontSize: 11,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            // Panel cover album
            OpenTunePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cover Album',
                    style: TextStyle(
                      color: OpenTuneColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih gambar untuk mewakili album kamu.',
                    style: TextStyle(
                      color: OpenTuneColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Center(
                    child: Column(
                      children: [
                        const SongCover(
                          coverImage: 'assets/images/covers/under-blue_cover.jpg',
                          width: 155,
                          height: 155,
                          radius: 9,
                          fallbackIcon: Icons.album_rounded,
                        ),
                        const SizedBox(height: 9),
                        TextButton.icon(
                          onPressed: () => _showWireframeMessage(
                            'Pemilihan cover belum dibuat pada wireframe.',
                          ),
                          icon: const Icon(
                            Icons.image_outlined,
                            size: 18,
                          ),
                          label: const Text('Pilih Cover'),
                          style: TextButton.styleFrom(
                            foregroundColor: OpenTuneColors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Panel informasi album
            OpenTunePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Album',
                    style: TextStyle(
                      color: OpenTuneColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Lengkapi informasi album untuk ditampilkan pada OpenTune.',
                    style: TextStyle(
                      color: OpenTuneColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 17),
                  const WireframeTextField(
                    label: 'Nama Album',
                    hint: 'Masukkan nama album',
                    initialValue: 'Under Blue',
                  ),
                  const SizedBox(height: 15),
                  const WireframeTextField(
                    label: 'Artis',
                    hint: 'Masukkan nama artis',
                    initialValue: 'Eve',
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Genre',
                    style: TextStyle(
                      color: OpenTuneColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  DropdownButtonFormField<String>(
                    initialValue: _genre,
                    isExpanded: true,
                    decoration: _dropdownDecoration(),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      color: OpenTuneColors.text,
                      fontSize: 13,
                    ),
                    items: const [
                      'JPop',
                      'Pop',
                      'Rock',
                      'Indie',
                      'R&B',
                      'Jazz',
                      'Electronic',
                    ].map((genre) {
                      return DropdownMenuItem<String>(
                        value: genre,
                        child: Text(genre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _genre = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 17),
                  const Text(
                    'File Lagu Album',
                    style: TextStyle(
                      color: OpenTuneColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  WireframeUploadTile(
                    icon: Icons.folder_zip_rounded,
                    title: 'Pilih File ZIP',
                    subtitle: 'Berisi kumpulan lagu · contoh tampilan',
                    onTap: () => _showWireframeMessage(
                      'Pemilihan ZIP belum dibuat pada wireframe.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            GradientButton(
              label: 'Upload Album',
              icon: Icons.cloud_upload_rounded,
              onPressed: () => _showWireframeMessage(
                'Tombol Upload Album hanya untuk tampilan wireframe.',
              ),
            ),

            const SizedBox(height: 9),

            const Text(
              'Area pemilihan berkas ini hanya berupa ilustrasi UI.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: OpenTuneColors.muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
