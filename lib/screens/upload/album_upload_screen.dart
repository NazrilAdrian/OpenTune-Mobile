import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/services/storage_service.dart';
import '../../features/song_artist_album/models/genre_model.dart';
import '../../features/song_artist_album/repositories/album_repository.dart';
import '../../features/song_artist_album/repositories/artist_repository.dart';
import '../../features/song_artist_album/repositories/genre_repository.dart';
import '../../features/song_artist_album/repositories/repository_guard.dart';
import '../../features/song_artist_album/repositories/song_repository.dart';
import '../../features/song_artist_album/services/album_zip_service.dart';
import '../../widgets/opentune_ui.dart';

class AlbumUploadScreen extends StatefulWidget {
  const AlbumUploadScreen({super.key});

  @override
  State<AlbumUploadScreen> createState() => _AlbumUploadScreenState();
}

class _AlbumUploadScreenState extends State<AlbumUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _artistController = TextEditingController();
  final _picker = ImagePicker();
  final _zipService = AlbumZipService();
  final _storage = StorageService();
  final _albums = AlbumRepository();
  final _songs = SongRepository();
  final _artists = ArtistRepository();
  final _genreRepository = GenreRepository();
  List<GenreModel> _genres = [];
  int? _genreId;
  Uint8List? _coverBytes;
  String? _coverName;
  String? _zipName;
  List<AlbumZipTrack> _tracks = [];
  Object? _genreError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await _genreRepository.getGenres();
      if (mounted) setState(() => _genres = genres);
    } catch (error) {
      if (mounted) setState(() => _genreError = error);
    }
  }

  Future<void> _pickCover() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      StorageService.validateFileContent(
          bytes, StorageBucket.covers, file.name);
      if (mounted) {
        setState(() {
          _coverBytes = bytes;
          _coverName = file.name;
        });
      }
    } catch (error) {
      if (mounted) _showWireframeMessage('Cover tidak dapat dipilih: $error');
    }
  }

  Future<void> _pickZip() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['zip'],
      );
      if (file == null) return;
      if (file.extension?.toLowerCase() != 'zip') {
        throw const FormatException('Pilih file dengan ekstensi .zip.');
      }
      final size = await file.length();
      if (size == null || size < 1 || size > AlbumZipService.maxZipInputBytes) {
        throw const FormatException('ZIP harus berukuran 1–50 MiB.');
      }
      final tracks = await _zipService.decode(await file.readAsBytes());
      if (mounted) {
        setState(() {
          _tracks = tracks;
          _zipName = file.name;
        });
      }
    } catch (error) {
      if (mounted) _showWireframeMessage('ZIP tidak dapat diproses: $error');
    }
  }

  Future<int> _durationFor(AlbumZipTrack track) async {
    final extension = track.fileName.split('.').last.toLowerCase();
    final mime = switch (extension) {
      'mp3' => 'audio/mpeg',
      'm4a' => 'audio/mp4',
      'wav' => 'audio/wav',
      _ => throw const FormatException('Format audio tidak didukung.'),
    };
    final player = AudioPlayer();
    try {
      final duration = await player.setAudioSource(AudioSource.uri(
        Uri.dataFromBytes(track.bytes, mimeType: mime),
      ));
      if (duration == null || duration.inSeconds < 1) {
        throw StateError('Durasi track "${track.title}" tidak dapat dibaca.');
      }
      return duration.inSeconds;
    } finally {
      await player.dispose();
    }
  }

  Future<void> _uploadAlbum() async {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;
    if (_coverBytes == null || _coverName == null || _tracks.isEmpty) {
      _showWireframeMessage('Pilih cover dan ZIP audio terlebih dahulu.');
      return;
    }
    if (_genreError != null) {
      _showWireframeMessage('Genre gagal dimuat: $_genreError');
      return;
    }
    setState(() => _busy = true);
    final audioUrls = <String>[];
    final coverUrls = <String>[];
    String? userId;
    var createdAlbumId = 0;
    try {
      userId = requireUserId();
      final artist = await _artists.findOrCreateArtist(_artistController.text);
      final durations = <int>[];
      for (final track in _tracks) {
        durations.add(await _durationFor(track));
      }
      coverUrls.add(await _storage.uploadCover(_coverBytes!, _coverName!,
          category: StorageCategory.albums));
      final album = await _albums.createAlbum({
        'artist_id': artist.artistId,
        'name': _nameController.text.trim(),
        'cover_path': coverUrls.single,
      });
      createdAlbumId = album.albumId;
      final songs = <Map<String, dynamic>>[];
      for (var i = 0; i < _tracks.length; i++) {
        final track = _tracks[i];
        final url = await _storage.uploadAudio(
          track.bytes,
          track.fileName,
          category: StorageCategory.albums,
          albumId: album.albumId,
          trackNumber: track.trackNumber,
        );
        audioUrls.add(url);
        songs.add({
          'artist_id': artist.artistId,
          'album_id': album.albumId,
          'genre_id': _genreId,
          'track_number': track.trackNumber,
          'title': track.title,
          'file_path': url,
          'cover_path': null,
          'duration': durations[i],
        });
      }
      await _songs.createSongs(songs);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Album berhasil diunggah.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      final cleanupIssues = <String>[];
      var canRemoveFiles = createdAlbumId == 0;
      if (createdAlbumId > 0) {
        try {
          await _albums.deleteAlbum(createdAlbumId, userId!);
          canRemoveFiles = true;
        } catch (failure) {
          cleanupIssues.add('$failure; album ID $createdAlbumId');
        }
      }
      if (canRemoveFiles) {
        try {
          await _storage.removeObjects(StorageBucket.audioFiles, audioUrls);
          await _storage.removeObjects(StorageBucket.covers, coverUrls);
        } catch (failure) {
          cleanupIssues.add('$failure; audio=$audioUrls, covers=$coverUrls');
        }
      } else {
        cleanupIssues
            .add('album=$createdAlbumId; audio=$audioUrls, covers=$coverUrls');
      }
      if (cleanupIssues.isNotEmpty) {
        debugPrint('Album upload cleanup failed: ${cleanupIssues.join('; ')}');
      }
      if (mounted) {
        _showWireframeMessage(cleanupIssues.isEmpty
            ? 'Upload album gagal: $error'
            : 'Upload gagal dan cleanup belum lengkap. Hubungi admin untuk pembersihan manual.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ============================================================
  // WIREFRAME MESSAGE
  // ============================================================

  void _showWireframeMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

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

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return Theme(
      data: currentTheme.copyWith(
        textTheme: currentTheme.textTheme.apply(
          fontFamily: 'Poppins',
        ),
        primaryTextTheme: currentTheme.primaryTextTheme.apply(
          fontFamily: 'Poppins',
        ),
      ),
      child: Scaffold(
        backgroundColor: OpenTuneColors.background,

        // The AppBar is removed to keep this page
        // consistent with the Upload Song screen.
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              const Center(
                child: Text(
                  'Upload Album',
                  style: TextStyle(
                    color: OpenTuneColors.purple,
                    fontSize: 26,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Upload a cover, enter the album details, and select song files to include in your album.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: OpenTuneColors.muted,
                  fontSize: 11,
                  height: 1.5,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // ALBUM COVER PANEL
              // ==================================================

              OpenTunePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Album Cover',
                      style: TextStyle(
                        color: OpenTuneColors.text,
                        fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose an image to represent your album.',
                      style: TextStyle(
                        color: OpenTuneColors.muted,
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 17),
                    Center(
                      child: Column(
                        children: [
                          _coverBytes == null
                              ? const SongCover(
                                  coverImage:
                                      'assets/images/covers/under_blue_cover.jpg',
                                  width: 155,
                                  height: 155,
                                  radius: 9,
                                  fallbackIcon: Icons.album_rounded,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.memory(
                                    _coverBytes!,
                                    width: 155,
                                    height: 155,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                          const SizedBox(height: 12),

                          // Choose album cover button.
                          _WhitePurpleButton(
                            icon: Icons.image_outlined,
                            label: 'Choose Cover',
                            compact: true,
                            onPressed: _busy ? null : _pickCover,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // ALBUM INFORMATION PANEL
              // ==================================================

              OpenTunePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Album Information',
                      style: TextStyle(
                        color: OpenTuneColors.text,
                        fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Complete the album details to display it on OpenTune.',
                      style: TextStyle(
                        color: OpenTuneColors.muted,
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          WireframeTextField(
                            label: 'Album Name',
                            hint: 'Enter album name',
                            controller: _nameController,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Nama album wajib diisi.'
                                    : null,
                          ),
                          const SizedBox(height: 15),
                          WireframeTextField(
                            label: 'Artist',
                            hint: 'Enter artist name',
                            controller: _artistController,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Nama artis wajib diisi.'
                                    : null,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Genre',
                            style: TextStyle(
                              color: OpenTuneColors.text,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 7),
                          DropdownButtonFormField<int>(
                            initialValue: _genreId,
                            isExpanded: true,
                            decoration: _dropdownDecoration(),
                            menuMaxHeight: 300,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              color: OpenTuneColors.text,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            items: _genres.map((genre) {
                              return DropdownMenuItem<int>(
                                value: genre.genreId,
                                child: Text(
                                  genre.name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: _busy
                                ? null
                                : (value) => setState(() => _genreId = value),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 17),

                    // ==================================================
                    // ALBUM SONG FILES
                    // ==================================================

                    const Text(
                      'Album Song Files',
                      style: TextStyle(
                        color: OpenTuneColors.text,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Gray background: #F3F4F6.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // ZIP icon on the left with an outline.
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: const Color(0xFFD1D1D8),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.folder_zip_rounded,
                              color: OpenTuneColors.muted,
                              size: 23,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ZIP file information.
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _zipName ?? 'No ZIP selected',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: OpenTuneColors.text,
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _tracks.isEmpty
                                      ? 'Select a ZIP containing audio tracks'
                                      : '${_tracks.length} audio tracks selected',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: OpenTuneColors.muted,
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Choose File button on the right.
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: _busy ? null : _pickZip,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFB8B8C0),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Choose File',
                                  style: TextStyle(
                                    color: OpenTuneColors.text,
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // UPLOAD ALBUM BUTTON
              // ==================================================

              _WhitePurpleButton(
                label: _busy ? 'Uploading…' : 'Upload Album',
                fullWidth: true,
                onPressed: _busy ? null : _uploadAlbum,
              ),

              const SizedBox(height: 10),

              // ==================================================
              // CANCEL BUTTON
              // ==================================================

              _WhitePurpleButton(
                label: 'Cancel',
                fullWidth: true,
                onPressed: _busy
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
              ),

              const SizedBox(height: 12),

              const Text(
                'ZIP up to 50MB · MP3, M4A or WAV',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: OpenTuneColors.muted,
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// WHITE BUTTON THAT TURNS PURPLE WHEN PRESSED
// ================================================================

class _WhitePurpleButton extends StatelessWidget {
  const _WhitePurpleButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        // White by default, purple when pressed.
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return OpenTuneColors.purple;
            }

            return Colors.white;
          },
        ),

        // Text and icon turn white when pressed.
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white;
            }

            return OpenTuneColors.purple;
          },
        ),

        // Button border.
        side: WidgetStateProperty.resolveWith<BorderSide>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return const BorderSide(
                color: OpenTuneColors.purple,
                width: 1.2,
              );
            }

            return const BorderSide(
              color: OpenTuneColors.border,
              width: 1,
            );
          },
        ),

        // Visual feedback when pressed.
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.10);
            }

            return OpenTuneColors.purple.withValues(alpha: 0.04);
          },
        ),

        minimumSize: WidgetStatePropertyAll<Size>(
          Size(0, compact ? 40 : 52),
        ),

        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            horizontal: compact ? 14 : 18,
            vertical: compact ? 9 : 14,
          ),
        ),

        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        textStyle: WidgetStatePropertyAll<TextStyle>(
          TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: compact ? 12 : 14,
          ),
        ),

        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      // Display the icon only when the icon parameter is provided.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon!,
              size: compact ? 18 : 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ],
      ),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
