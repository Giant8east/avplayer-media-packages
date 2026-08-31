import 'dart:async';

import 'package:avplayer_audio_service/avplayer_audio_service.dart';

import 'notification_playback_gateway.dart';
import 'notification_playback_snapshot.dart';

/// Adapts host playback state and system media commands for `avplayer_audio_service`.
///
/// The handler subscribes to [NotificationPlaybackGateway.snapshots], publishes
/// each update to platform media controls, and delegates platform commands back
/// to the host application through the gateway.
class NotificationAudioHandler extends BaseAudioHandler {
  NotificationAudioHandler(this._gateway) {
    _snapshotSubscription = _gateway.snapshots.listen(_publishSnapshot);
  }

  final NotificationPlaybackGateway _gateway;
  late final StreamSubscription<NotificationPlaybackSnapshot>
  _snapshotSubscription;

  /// Publishes the latest host snapshot immediately after initialization.
  Future<void> synchronize() async {
    _publishSnapshot(_gateway.currentSnapshot);
  }

  @override
  Future<void> play() => _gateway.play();

  @override
  Future<void> pause() => _gateway.pause();

  @override
  Future<void> skipToNext() => _gateway.skipToNext();

  @override
  Future<void> skipToPrevious() => _gateway.skipToPrevious();

  @override
  Future<void> seek(Duration position) => _gateway.seek(position);

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    switch (button) {
      case MediaButton.media:
        if (playbackState.value.playing == true) {
          await pause();
        } else {
          await play();
        }
        break;
      case MediaButton.next:
        await skipToNext();
        break;
      case MediaButton.previous:
        await skipToPrevious();
        break;
    }
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == _toggleFavoriteAction) {
      await _gateway.changeLike();
      return true;
    }
    return super.customAction(name, extras);
  }

  @override
  Future<void> stop() async {
    await _gateway.stop();
    await _snapshotSubscription.cancel();
    await super.stop();
  }

  static const _toggleFavoriteAction = 'toggle_favorite';

  /// Android custom action that removes the active track from favorites.
  static final _favoriteControl = MediaControl.custom(
    androidIcon: 'drawable/ic_notification_favorite',
    label: 'Remove from favorites',
    name: _toggleFavoriteAction,
    extras: const {'androidNativeNotificationAction': true},
  );

  /// Android custom action that adds the active track to favorites.
  static final _favoriteBorderControl = MediaControl.custom(
    androidIcon: 'drawable/ic_notification_favorite_border',
    label: 'Add to favorites',
    name: _toggleFavoriteAction,
    extras: const {'androidNativeNotificationAction': true},
  );

  static const _skipPreviousControl = MediaControl(
    androidIcon: 'drawable/ic_notif_prev_outline',
    label: 'Previous',
    action: MediaAction.skipToPrevious,
  );

  static const _playControl = MediaControl(
    androidIcon: 'drawable/ic_notif_play_outline',
    label: 'Play',
    action: MediaAction.playPause,
  );

  static const _pauseControl = MediaControl(
    androidIcon: 'drawable/ic_notif_pause_outline',
    label: 'Pause',
    action: MediaAction.playPause,
  );

  static const _skipNextControl = MediaControl(
    androidIcon: 'drawable/ic_notif_next_outline',
    label: 'Next',
    action: MediaAction.skipToNext,
  );

  /// Publishes track metadata and playback state for the supplied snapshot.
  void _publishSnapshot(NotificationPlaybackSnapshot snapshot) {
    _publishMediaItem(snapshot.track);
    playbackState.add(
      PlaybackState(
        controls: [
          snapshot.isFavorite ? _favoriteControl : _favoriteBorderControl,
          _skipPreviousControl,
          snapshot.isPlaying ? _pauseControl : _playControl,
          _skipNextControl,
        ],
        systemActions: const {MediaAction.seek},
        processingState: _toAudioProcessingState(snapshot.phase),
        playing: snapshot.isPlaying,
        updatePosition: snapshot.position,
        bufferedPosition: snapshot.bufferedPosition,
        speed: snapshot.speed,
      ),
    );
  }

  /// Updates platform metadata, including artwork and authenticated artwork headers.
  void _publishMediaItem(NotificationTrack? track) {
    mediaItem.add(
      track == null
          ? null
          : MediaItem(
              id: track.id,
              title: track.title,
              album: track.album,
              artist: track.artist,
              duration: track.duration,
              artUri: track.artworkUri,
              artHeaders: track.artworkHeaders,
            ),
    );
  }

  /// Maps the package playback phase to the audio-service processing state.
  AudioProcessingState _toAudioProcessingState(
    NotificationPlaybackPhase phase,
  ) => switch (phase) {
    NotificationPlaybackPhase.idle => AudioProcessingState.idle,
    NotificationPlaybackPhase.loading => AudioProcessingState.loading,
    NotificationPlaybackPhase.buffering => AudioProcessingState.buffering,
    NotificationPlaybackPhase.ready => AudioProcessingState.ready,
    NotificationPlaybackPhase.completed => AudioProcessingState.completed,
    NotificationPlaybackPhase.error => AudioProcessingState.error,
  };
}
