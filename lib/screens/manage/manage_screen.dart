import 'package:flutter/material.dart';

import '../../widgets/opentune_ui.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  int _selectedTab = 0;

  final List<TrackData> _songs = const [
    TrackData(
      title: 'Setsunarensa',
      artist: 'Radwimps',
      seed: 'setsunarensa',
    ),
    TrackData(
      title: 'Dramaturgy',
      artist: 'Eve',
      seed: 'dramaturgy',
    ),
    TrackData(
      title: 'Saikai',
      artist: 'Vaundy',
      seed: 'saikai',
    ),
  ];

  final List<TrackData> _albums = const [
    TrackData(
      title: 'Under Blue',
      artist: 'Eve',
      seed: 'under-blue',
    ),
    TrackData(
      title: 'RADWIMPS 4',
      artist: 'Radwimps',
      seed: 'radwimps-4',
    ),
  ];

  void _showActionMessage(String action, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$action "$title" — tampilan wireframe saja.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _selectedTab == 0 ? _songs : _albums;

    return Scaffold(
      backgroundColor: OpenTuneColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage',
                    style: TextStyle(
                      color: OpenTuneColors.text,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Manage your uploaded songs and albums.',
                    style: TextStyle(
                      color: OpenTuneColors.muted,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 21),

                  // Tab Song / Album.
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDF2),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      children: [
                        _tabButton(
                          label: 'Song (${_songs.length})',
                          index: 0,
                        ),
                        _tabButton(
                          label: 'Album (${_albums.length})',
                          index: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 11),
                itemBuilder: (context, index) {
                  final item = items[index];

                  return OpenTunePanel(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        SongCover(
                          seed: item.seed,
                          width: 58,
                          height: 58,
                          radius: 6,
                          fallbackIcon: _selectedTab == 0
                              ? Icons.music_note_rounded
                              : Icons.album_rounded,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: OpenTuneColors.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: OpenTuneColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                _selectedTab == 0
                                    ? 'Uploaded song'
                                    : 'Uploaded album',
                                style: const TextStyle(
                                  color: OpenTuneColors.purple,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _showActionMessage(
                            'Edit',
                            item.title,
                          ),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: OpenTuneColors.muted,
                            size: 20,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _showActionMessage(
                            'Delete',
                            item.title,
                          ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFD95365),
                            size: 21,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required int index,
  }) {
    final selected = _selectedTab == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? OpenTuneColors.purple : OpenTuneColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
