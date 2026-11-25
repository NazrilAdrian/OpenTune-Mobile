
import 'package:flutter/material.dart';

import '../../widgets/opentune_ui.dart';

class SongUploadScreen extends StatefulWidget {
  const SongUploadScreen({super.key});

  @override
  State<SongUploadScreen> createState() => _SongUploadScreenState();
}

class _SongUploadScreenState extends State<SongUploadScreen> {
  String _genre = 'JPop';

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
                          const SongCover(
                            coverImage:
                                'assets/images/covers/setsunarensa_cover.jpg',
                            width: 155,
                            height: 155,
                            radius: 9,
                          ),

                          const SizedBox(height: 12),

                          // Choose cover button
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

                    const SizedBox(height: 17),

                    const WireframeTextField(
                      label: 'Song Title',
                      hint: 'Enter song title',
                      initialValue: 'Setsunarensa',
                    ),

                    const SizedBox(height: 15),

                    const WireframeTextField(
                      label: 'Artist',
                      hint: 'Enter artist name',
                      initialValue: 'Radwimps',
                    ),

                    const SizedBox(height: 15),

                    const WireframeTextField(
                      label: 'Album (Optional)',
                      hint: 'Select or enter album',
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
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Setsunarensa.mp3',
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
                                  'MP3 or M4A · Max. 50MB',
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
                              onTap: () {
                                _showWireframeMessage(
                                  'Audio selection is not implemented in this wireframe.',
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
              // UPLOAD SONG BUTTON
              // ==================================================

              _WhitePurpleButton(
                label: 'Upload Song',
                fullWidth: true,
                onPressed: () {
                  _showWireframeMessage(
                    'The Upload Song button is for wireframe demonstration only.',
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
  final VoidCallback onPressed;
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
