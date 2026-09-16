import 'dart:async';

import 'package:avplayer_audio_service/avplayer_audio_service.dart';

import 'notification_controls.dart';
import 'notification_media_session_config.dart';
import 'notification_playback_gateway.dart';
import 'notification_playback_snapshot.dart';

/// Adapts host playback state and system media commands for `avplayer_audio_service`.
///
/// The handler subscribes to [NotificationPlaybackGateway.snapshots], publishes
/// each update to platform media controls, and delegates platform commands back
/// to the host application through the gateway.
class NotificationAudioHandler extends BaseAudioHandler {
  NotificationAudioHandler(
    this._gateway, {
    NotificationMediaSessionConfig? config,
  }) : _config =
           config ??
           const NotificationMediaSessionConfig(
             androidNotificationChannelId: 'default',
             androidNotificationChannelName: 'Playback',
           ) {
    _gateway.snapshots.listen(_publishSnapshot);
  }

  final NotificationPlaybackGateway _gateway;
  final NotificationMediaSessionConfig _config;
  bool _notificationDismissed = false;
  bool _waitingForDismissedPause = false;

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
    if (name == NotificationControls.noopSpacerAction) {
      return true;
    }
    if (name == NotificationControls.toggleFavoriteAction) {
      await _gateway.changeLike();
      return true;
    }
    if (_config.onCustomAction != null) {
      final result = await _config.onCustomAction!(name, extras);
      if (result != null) return result;
    }
    final gatewayResult = await _gateway.onCustomAction(name, extras);
    if (gatewayResult != null) return gatewayResult;
    return super.customAction(name, extras);
  }

  @override
  Future<void> onNotificationDeleted() async {
    _notificationDismissed = true;
    _waitingForDismissedPause = true;
    await _gateway.onNotificationDeleted();
  }

  @override
  Future<void> stop() async {
    await _gateway.stop();
    await super.stop();
  }

  /// Publishes track metadata and playback state for the supplied snapshot.
  void _publishSnapshot(NotificationPlaybackSnapshot snapshot) {
    if (_notificationDismissed) {
      if (_waitingForDismissedPause) {
        if (!snapshot.isPlaying) {
          _waitingForDismissedPause = false;
        }
        return;
      }
      if (!snapshot.isPlaying) return;
      _notificationDismissed = false;
    }

    _publishMediaItem(snapshot.track);

    final controls =
        _config.controlsBuilder?.call(snapshot) ??
        NotificationControls.defaultControls(snapshot);

    final systemActions =
        _config.systemActionsBuilder?.call(snapshot) ??
        const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        };

    final compactIndices =
        _config.androidCompactActionIndicesBuilder?.call(snapshot, controls) ??
        _defaultCompactIndices(controls);

    playbackState.add(
      PlaybackState(
        controls: controls,
        androidCompactActionIndices: compactIndices,
        systemActions: systemActions,
        processingState: _toAudioProcessingState(snapshot.phase),
        playing: snapshot.isPlaying,
        updatePosition: snapshot.position,
        bufferedPosition: snapshot.bufferedPosition,
        speed: snapshot.speed,
      ),
    );
  }

  /// Calculates compact action indices by filtering out placeholder spacers.
  List<int> _defaultCompactIndices(List<MediaControl> controls) {
    final nonSpacerIndices = <int>[];
    for (var i = 0; i < controls.length; i++) {
      final control = controls[i];
      final isSpacer =
          control.androidIcon == 'drawable/ic_notif_spacer' ||
          control.customAction?.name == NotificationControls.noopSpacerAction;
      if (!isSpacer) {
        nonSpacerIndices.add(i);
      }
    }
    if (nonSpacerIndices.isEmpty) {
      return List.generate(controls.length > 3 ? 3 : controls.length, (i) => i);
    }
    return nonSpacerIndices.take(3).toList();
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
