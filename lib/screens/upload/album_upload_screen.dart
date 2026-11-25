import 'package:flutter/material.dart';
import '../../widgets/opentune_ui.dart';

class AlbumUploadScreen extends StatefulWidget {
  const AlbumUploadScreen({super.key});

  @override
  State<AlbumUploadScreen> createState() => _AlbumUploadScreenState();
}

class _AlbumUploadScreenState extends State<AlbumUploadScreen> {
  String _genre = 'JPop';

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
                          const SongCover(
                            coverImage:
                                'assets/images/covers/under_blue_cover.jpg',
                            width: 155,
                            height: 155,
                            radius: 9,
                            fallbackIcon: Icons.album_rounded,
                          ),

                          const SizedBox(height: 12),

                          // Choose album cover button.
                          _WhitePurpleButton(
                            icon: Icons.image_outlined,
                            label: 'Choose Cover',
                            compact: true,
                            onPressed: () {
                              _showWireframeMessage(
                                'Cover selection is not implemented in this wireframe.',
                              );
                            },
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

                    const SizedBox(height: 17),

                    const WireframeTextField(
                      label: 'Album Name',
                      hint: 'Enter album name',
                      initialValue: 'Under Blue',
                    ),

                    const SizedBox(height: 15),

                    const WireframeTextField(
                      label: 'Artist',
                      hint: 'Enter artist name',
                      initialValue: 'Eve',
                    ),

                    const SizedBox(height: 15),

                    // GENRE
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

                    DropdownButtonFormField<String>(
                      initialValue: _genre,
                      isExpanded: true,
                      decoration: _dropdownDecoration(),
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        color: OpenTuneColors.text,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
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
                          child: Text(
                            genre,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
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
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UnderBlue.zip',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: OpenTuneColors.text,
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  'Contains multiple songs',
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

                          // Choose File button on the right.
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () {
                                _showWireframeMessage(
                                  'ZIP file selection is not implemented in this wireframe.',
                                );
                              },
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
                label: 'Upload Album',
                fullWidth: true,
                onPressed: () {
                  _showWireframeMessage(
                    'The Upload Album button is for wireframe demonstration only.',
                  );
                },
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
                'File selection is currently a UI demonstration only.',
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
  final VoidCallback onPressed;
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