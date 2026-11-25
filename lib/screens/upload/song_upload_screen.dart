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
import '../../widgets/opentune_ui.dart';

class SongUploadScreen extends StatefulWidget {
  const SongUploadScreen({super.key});

  @override
  State<SongUploadScreen> createState() => _SongUploadScreenState();
}

class _SongUploadScreenState extends State<SongUploadScreen> {
  static const _maxAudioBytes = 50 * 1024 * 1024;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  final _picker = ImagePicker();
  final _storage = StorageService();
  final _songs = SongRepository();
  final _artists = ArtistRepository();
  final _albums = AlbumRepository();
  final _genreRepository = GenreRepository();
  List<GenreModel> _genres = [];
  int? _genreId;
  Uint8List? _coverBytes;
  String? _coverName;
  Uint8List? _audioBytes;
  String? _audioName;
  Uri? _audioUri;
  Object? _genreError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
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

  Future<void> _pickAudio() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['mp3', 'm4a', 'wav'],
      );
      if (file == null) return;
      final size = await file.length();
      if (size == null) throw StateError('Ukuran file audio tidak diketahui.');
      if (size > _maxAudioBytes) {
        throw StateError('Ukuran audio melebihi batas 50 MB.');
      }
      final bytes = await file.readAsBytes();
      StorageService.validateFileContent(
          bytes, StorageBucket.audioFiles, file.name);
      if (mounted) {
        setState(() {
          _audioBytes = bytes;
          _audioName = file.name;
          _audioUri = file.uri;
        });
      }
    } catch (error) {
      if (mounted) _showWireframeMessage('Audio tidak dapat dipilih: $error');
    }
  }

  Future<int> _readDurationSeconds() async {
    final uri = _audioUri;
    if (uri == null) {
      throw StateError('Durasi audio tidak dapat dibaca dari file terpilih.');
    }
    final player = AudioPlayer();
    try {
      final duration = await player.setAudioSource(AudioSource.uri(uri));
      if (duration == null || duration.inSeconds < 1) {
        throw StateError('Durasi audio tidak valid atau tidak dapat dibaca.');
      }
      return duration.inSeconds;
    } finally {
      await player.dispose();
    }
  }

  Future<void> _uploadSong() async {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;
    if (_audioBytes == null || _audioName == null) {
      _showWireframeMessage('Pilih file audio terlebih dahulu.');
      return;
    }
    if (_genreError != null) {
      _showWireframeMessage('Genre gagal dimuat: $_genreError');
      return;
    }

    setState(() => _busy = true);
    final uploadedCovers = <String>[];
    final uploadedAudio = <String>[];
    try {
      final userId = requireUserId();
      final artist = await _artists.findOrCreateArtist(_artistController.text);
      final albumName = _albumController.text.trim();
      final albumId = albumName.isEmpty
          ? null
          : await _albums.findOwnedAlbumId(
              name: albumName,
              artistId: artist.artistId,
              userId: userId,
            );
      if (albumName.isNotEmpty && albumId == null) {
        throw StateError(
            'Album tidak ditemukan untuk akun aktif dan artis tersebut.');
      }
      final duration = await _readDurationSeconds();
      final trackNumber = albumId == null
          ? null
          : await _songs.nextTrackNumber(albumId, userId);

      if (_coverBytes != null && _coverName != null) {
        uploadedCovers.add(await _storage.uploadCover(
          _coverBytes!,
          _coverName!,
          category: StorageCategory.songs,
        ));
      }
      uploadedAudio.add(await _storage.uploadAudio(
        _audioBytes!,
        _audioName!,
        category: StorageCategory.songs,
      ));

      await _songs.createSong({
        'artist_id': artist.artistId,
        'album_id': albumId,
        'track_number': trackNumber,
        'genre_id': _genreId,
        'title': _titleController.text.trim(),
        'file_path': uploadedAudio.single,
        'cover_path': uploadedCovers.isEmpty ? null : uploadedCovers.single,
        'duration': duration,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lagu berhasil diunggah.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      try {
        await _storage.removeObjects(StorageBucket.audioFiles, uploadedAudio);
        await _storage.removeObjects(StorageBucket.covers, uploadedCovers);
      } catch (cleanupError) {
        debugPrint('Upload cleanup failed: $cleanupError');
      }
      if (mounted) _showWireframeMessage('Upload lagu gagal: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ============================================================
  // WIREFRAME MESSAGES
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
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              const Center(
                child: Text(
                  'Upload Song',
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
                'Upload a cover, enter the song details, and select an audio file to publish.',
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
              // SONG COVER PANEL
              // ==================================================

              OpenTunePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Song Cover',
                      style: TextStyle(
                        color: OpenTuneColors.text,
                        fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Use a clear image to represent your song.',
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
                                      'assets/images/covers/setsunarensa_cover.jpg',
                                  width: 155,
                                  height: 155,
                                  radius: 9,
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

                          // Choose cover button
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
              // SONG INFORMATION PANEL
              // ==================================================

              OpenTunePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Song Information',
                      style: TextStyle(
                        color: OpenTuneColors.text,
                        fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Enter the song details to help listeners find and understand it.',
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
                            label: 'Song Title',
                            hint: 'Enter song title',
                            controller: _titleController,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Judul lagu wajib diisi.'
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
                          WireframeTextField(
                            label: 'Album (Optional)',
                            hint: 'Select or enter album',
                            controller: _albumController,
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
                    // AUDIO FILE
                    // ==================================================

                    const Text(
                      'Audio File',
                      style: TextStyle(
                        color: OpenTuneColors.text,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Audio file area with a light gray background.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Audio icon with a gray outline.
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
                              Icons.audio_file_rounded,
                              color: OpenTuneColors.muted,
                              size: 23,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Audio file information.
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _audioName ?? 'No audio selected',
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
                                const Text(
                                  'MP3, M4A or WAV · Max. 50MB',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

                          const SizedBox(width: 8),

                          // Choose File button.
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: _busy ? null : _pickAudio,
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
              // UPLOAD SONG BUTTON
              // ==================================================

              _WhitePurpleButton(
                label: _busy ? 'Uploading…' : 'Upload Song',
                fullWidth: true,
                onPressed: _busy ? null : _uploadSong,
              ),

              const SizedBox(height: 10),

              // ==================================================
              // CANCEL BUTTON
              // ==================================================

              _WhitePurpleButton(
                label: 'Cancel',
                fullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 12),

              const Text(
                'Make sure your audio file matches the supported format.',
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
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return OpenTuneColors.purple;
            }

            return Colors.white;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white;
            }

            return OpenTuneColors.purple;
          },
        ),
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

      // Display an icon only when one is provided.
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
