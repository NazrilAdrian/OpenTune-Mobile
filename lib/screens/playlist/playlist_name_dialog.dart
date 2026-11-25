import 'package:flutter/material.dart';

import 'playlist_model.dart';

/// Dialog input nama playlist, dipakai untuk membuat DAN mengubah nama.
/// Mengembalikan nama (String) jika dikonfirmasi, atau null jika "Batal".
class PlaylistNameDialog extends StatefulWidget {
  final String title;
  final String description;
  final String confirmLabel;
  final String initialName;

  /// Nama playlist lain (tanpa playlist yang sedang diedit) untuk cek duplikat.
  final List<String> existingNames;

  const PlaylistNameDialog({
    super.key,
    required this.existingNames,
    this.title = 'Playlist Baru',
    this.description = 'Beri nama untuk playlist kamu.',
    this.confirmLabel = 'Buat',
    this.initialName = '',
  });

  @override
  State<PlaylistNameDialog> createState() => _PlaylistNameDialogState();
}

class _PlaylistNameDialogState extends State<PlaylistNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

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
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      title: Text(
        widget.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'Nama playlist',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              errorText: _isDuplicate && _name.isNotEmpty
                  ? 'Nama playlist sudah digunakan'
                  : null,
              counterText: '',
              filled: true,
              fillColor: AppColors.background,
              prefixIcon: const Icon(
                Icons.queue_music_rounded,
                color: AppColors.primary,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
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
            foregroundColor: AppColors.textSecondary,
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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primaryLight,
            disabledForegroundColor: AppColors.textSecondary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.confirmLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
