import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/song_artist_album/models/song_model.dart';
import '../../features/song_artist_album/repositories/song_repository.dart';

late OpenTuneAudioHandler openTuneAudioHandler;
bool _notificationPermissionAsked = false;

Future<void> requestPlaybackNotificationPermission(BuildContext context) async {
  if (defaultTargetPlatform != TargetPlatform.android ||
      _notificationPermissionAsked) {
    return;
  }
  _notificationPermissionAsked = true;
  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Playback notification'),
      content: const Text(
          'Izinkan notifikasi untuk mengontrol musik saat aplikasi diminimalkan atau layar terkunci.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nanti')),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lanjutkan')),
      ],
    ),
  );
  if (accepted != true) return;
  try {
    await const MethodChannel('opentune/notifications')
        .invokeMethod<bool>('request');
  } on PlatformException catch (error) {
    debugPrint('Notification permission request failed: $error');
  }
}

class OpenTuneAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  OpenTuneAudioHandler({SongRepository? songs})
      : _songs = songs ?? SongRepository() {
    _ready = _init();
  }

  final AudioPlayer player = AudioPlayer();
  final SongRepository _songs;
  late final Future<void> _ready;
  StreamSubscription<PlaybackEvent>? _eventSubscription;
  StreamSubscription<int?>? _indexSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<bool>? _shuffleSubscription;
  StreamSubscription<LoopMode>? _loopSubscription;
  int? _lastRecordedSong;
  bool isMuted = false;

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    session.becomingNoisyEventStream.listen((_) => pause());
    _eventSubscription =
        player.playbackEventStream.listen((_) => _broadcastState());
    _stateSubscription = player.playerStateStream.listen((state) {
      _broadcastState();
      if (state.playing && player.processingState == ProcessingState.ready) {
        _recordCurrentPlay();
      }
    });
    _indexSubscription = player.currentIndexStream.listen((index) {
      final items = queue.value;
      if (index != null && index >= 0 && index < items.length) {
        mediaItem.add(items[index]);
        _lastRecordedSong = null;
        if (player.playing && player.processingState == ProcessingState.ready) {
          _recordCurrentPlay();
        }
      }
      _broadcastState();
    });
    _shuffleSubscription =
        player.shuffleModeEnabledStream.listen((_) => _broadcastState());
    _loopSubscription = player.loopModeStream.listen((_) => _broadcastState());
  }

  MediaItem _media(SongModel song) => MediaItem(
        id: song.songId.toString(),
        title: song.title,
        artist: song.artistName ?? '',
        album: song.albumName ?? '',
        duration: Duration(seconds: song.duration),
        artUri: Uri.tryParse(song.coverPath ?? song.albumCoverPath ?? ''),
        extras: {'songId': song.songId},
      );

  Future<void> playSongs(List<SongModel> songs, {int startIndex = 0}) async {
    if (songs.isEmpty || startIndex < 0 || startIndex >= songs.length) return;
    await _ready;
    final items = songs.map(_media).toList();
    queue.add(items);
    _lastRecordedSong = null;
    try {
      await player.setAudioSources(
          songs
              .map((song) => AudioSource.uri(Uri.parse(song.filePath)))
              .toList(),
          initialIndex: startIndex);
      mediaItem.add(items[startIndex]);
      await play();
    } catch (error, stack) {
      debugPrint('Audio playback failed: $error\n$stack');
      playbackState.add(playbackState.value.copyWith(errorMessage: '$error'));
      rethrow;
    }
  }

  Future<void> playSong(SongModel song) => playSongs([song]);

  @override
  Future<void> play() async {
    await player.play();
  }

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (player.hasNext) await player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (player.hasPrevious) {
      await player.seekToPrevious();
    } else {
      await player.seek(Duration.zero);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < queue.value.length) {
      await player.seek(Duration.zero, index: index);
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode mode) async {
    await player.setShuffleModeEnabled(mode == AudioServiceShuffleMode.all ||
        mode == AudioServiceShuffleMode.group);
    if (player.shuffleModeEnabled) await player.shuffle();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode mode) =>
      player.setLoopMode(switch (mode) {
        AudioServiceRepeatMode.one => LoopMode.one,
        AudioServiceRepeatMode.all ||
        AudioServiceRepeatMode.group =>
          LoopMode.all,
        _ => LoopMode.off,
      });

  Future<void> setMuted(bool muted) async {
    isMuted = muted;
    await player.setVolume(muted ? 0 : 1);
  }

  void _recordCurrentPlay() {
    final index = player.currentIndex;
    final items = queue.value;
    if (index == null || index < 0 || index >= items.length) return;
    final songId = int.tryParse(items[index].id);
    if (songId == null || songId == _lastRecordedSong) return;
    _lastRecordedSong = songId;
    _songs.recordPlay(songId).catchError((Object error) {
      debugPrint('Could not record song play: $error');
    });
  }

  void _broadcastState() {
    final playing = player.playing;
    final controls = <MediaControl>[
      MediaControl.skipToPrevious,
      if (playing) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
    ];
    playbackState.add(PlaybackState(
      controls: controls,
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: switch (player.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: player.currentIndex,
      shuffleMode: player.shuffleModeEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: switch (player.loopMode) {
        LoopMode.one => AudioServiceRepeatMode.one,
        LoopMode.all => AudioServiceRepeatMode.all,
        _ => AudioServiceRepeatMode.none,
      },
    ));
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  @override
  Future<void> onNotificationDeleted() => stop();

  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _indexSubscription?.cancel();
    await _stateSubscription?.cancel();
    await _shuffleSubscription?.cancel();
    await _loopSubscription?.cancel();
    await player.dispose();
  }
}
