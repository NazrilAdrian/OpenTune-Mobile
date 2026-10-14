import 'package:flutter/material.dart';

import '../../widgets/opentune_ui.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchEntry {
  final String title;
  final String type;
  final IconData icon;

  const _SearchEntry({
    required this.title,
    required this.type,
    required this.icon,
  });
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  String _query = '';

  final List<_SearchEntry> _history = [
    const _SearchEntry(
      title: 'Dramaturgy',
      type: 'Song',
      icon: Icons.music_note_rounded,
    ),
    const _SearchEntry(
      title: 'Under Blue',
      type: 'Album',
      icon: Icons.album_rounded,
    ),
    const _SearchEntry(
      title: 'Eve',
      type: 'Artist',
      icon: Icons.person_rounded,
    ),
    const _SearchEntry(
      title: 'Setsunarensa',
      type: 'Song',
      icon: Icons.music_note_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  void _selectHistory(_SearchEntry entry) {
    setState(() {
      _controller.text = entry.title;
      _query = entry.title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();

    final matchingSongs = searchSongTracks.where((track) {
      return track.title.toLowerCase().contains(query) ||
          track.artist.toLowerCase().contains(query);
    }).toList();

    final matchingAlbums = searchAlbumTracks.where((album) {
      return album.title.toLowerCase().contains(query) ||
          album.artist.toLowerCase().contains(query);
    }).toList();

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
                fontWeight: FontWeight.w800,
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

            // Search bar persegi panjang seperti website.
            TextField(
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
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
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: OpenTuneColors.muted,
                        ),
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

            const SizedBox(height: 27),

            if (query.isEmpty) ...[
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Searches',
                      style: TextStyle(
                        color: OpenTuneColors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_history.isNotEmpty)
                    TextButton(
                      onPressed: _clearHistory,
                      style: TextButton.styleFrom(
                        foregroundColor: OpenTuneColors.purple,
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Text(
                    'No recent searches.',
                    style: TextStyle(
                      color: OpenTuneColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ..._history.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _HistoryTile(
                    entry: entry,
                    onTap: () => _selectHistory(entry),
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Result for "$_query"',
                style: const TextStyle(
                  color: OpenTuneColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 22),
              if (matchingSongs.isNotEmpty)
                _SearchResultSection(
                  title: 'Song',
                  tracks: matchingSongs,
                ),
              if (matchingSongs.isNotEmpty && matchingAlbums.isNotEmpty)
                const SizedBox(height: 24),
              if (matchingAlbums.isNotEmpty)
                _SearchResultSection(
                  title: 'Album',
                  tracks: matchingAlbums,
                ),
              if (matchingSongs.isEmpty && matchingAlbums.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 35),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 40,
                          color: OpenTuneColors.muted,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No matching dummy results.',
                          style: TextStyle(
                            color: OpenTuneColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final _SearchEntry entry;
  final VoidCallback onTap;

  const _HistoryTile({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: OpenTuneColors.border,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.history_rounded,
                color: OpenTuneColors.muted,
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        color: OpenTuneColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entry.type,
                      style: const TextStyle(
                        color: OpenTuneColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.north_west_rounded,
                color: OpenTuneColors.muted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultSection extends StatelessWidget {
  final String title;
  final List<TrackData> tracks;

  const _SearchResultSection({
    required this.title,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: OpenTuneColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 137,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tracks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, index) {
              final track = tracks[index];

              return SizedBox(
                width: 108,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SongCover(
                      seed: track.seed,
                      width: 108,
                      height: 88,
                      radius: 5,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: OpenTuneColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: OpenTuneColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
