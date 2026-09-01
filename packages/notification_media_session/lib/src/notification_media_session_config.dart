import 'package:avplayer_audio_service/avplayer_audio_service.dart';

import 'notification_controls.dart';
import 'notification_playback_snapshot.dart';

/// Builder function returning the list of [MediaControl]s for a given [snapshot].
typedef NotificationControlsBuilder = List<MediaControl> Function(
  NotificationPlaybackSnapshot snapshot,
);

/// Builder function returning the set of supported [MediaAction]s for a given [snapshot].
typedef NotificationSystemActionsBuilder = Set<MediaAction> Function(
  NotificationPlaybackSnapshot snapshot,
);

/// Callback signature for handling custom action dispatch.
typedef NotificationCustomActionCallback = Future<dynamic> Function(
  String name,
  Map<String, dynamic>? extras,
);

/// Builder function returning the list of compact action indices for Android notification view.
typedef NotificationCompactActionIndicesBuilder = List<int>? Function(
  NotificationPlaybackSnapshot snapshot,
  List<MediaControl> controls,
);

/// Host-owned configuration used to initialize the platform media session.
class NotificationMediaSessionConfig {
  const NotificationMediaSessionConfig({
    required this.androidNotificationChannelId,
    required this.androidNotificationChannelName,
    this.androidStopForegroundOnPause = false,
    this.androidNotificationIcon,
    this.controlsBuilder,
    this.systemActionsBuilder,
    this.androidCompactActionIndicesBuilder,
    this.onCustomAction,
  });

  /// Android notification-channel identifier for playback notifications.
  final String androidNotificationChannelId;

  /// Human-readable Android notification-channel name.
  final String androidNotificationChannelName;

  /// Whether Android should stop the foreground service when playback pauses.
  final bool androidStopForegroundOnPause;

  /// Small notification status bar icon on Android (defaults to app launcher icon).
  final String? androidNotificationIcon;

  /// Optional custom builder for notification controls.
  ///
  /// If omitted, defaults to [NotificationControls.defaultControls].
  final NotificationControlsBuilder? controlsBuilder;

  /// Optional custom builder for system media actions.
  ///
  /// If omitted, defaults to `{MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward}`.
  final NotificationSystemActionsBuilder? systemActionsBuilder;

  /// Optional custom builder for compact notification action indices on Android.
  ///
  /// If omitted, transparent spacer controls are automatically filtered out.
  final NotificationCompactActionIndicesBuilder?
      androidCompactActionIndicesBuilder;

  /// Optional handler callback for custom actions.
  ///
  /// If provided, this is called before delegating to [NotificationPlaybackGateway.onCustomAction].
  final NotificationCustomActionCallback? onCustomAction;

  /// Converts this package configuration to the underlying audio-service config.
  AudioServiceConfig toAudioServiceConfig() => AudioServiceConfig(
    androidNotificationChannelId: androidNotificationChannelId,
    androidNotificationChannelName: androidNotificationChannelName,
    androidStopForegroundOnPause: androidStopForegroundOnPause,
    androidNotificationIcon:
        androidNotificationIcon ?? 'mipmap/ic_launcher',
  );
}
