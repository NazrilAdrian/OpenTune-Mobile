import 'package:flutter/material.dart';
import '../../widgets/opentune_ui.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenTuneColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
          children: [
            const Text(
              'Search',
              style: TextStyle(
                color: OpenTuneColors.text,
                fontSize: 26,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Find your favorite songs and albums.',
              style: TextStyle(
                color: OpenTuneColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 21),
            TextField(
              showCursor: true,
              enableInteractiveSelection: true,
              style: const TextStyle(
                color: OpenTuneColors.text,
                fontSize: 14,
              ),
              cursorColor: OpenTuneColors.purple,
              decoration: InputDecoration(
                hintText: 'Search song or album...',
                hintStyle: const TextStyle(
                  color: OpenTuneColors.muted,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: OpenTuneColors.purple,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: OpenTuneColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: OpenTuneColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: OpenTuneColors.purple,
                    width: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
