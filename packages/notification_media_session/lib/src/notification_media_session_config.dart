import 'package:avplayer_audio_service/avplayer_audio_service.dart';

/// Host-owned configuration used to initialize the platform media session.
class NotificationMediaSessionConfig {
  const NotificationMediaSessionConfig({
    required this.androidNotificationChannelId,
    required this.androidNotificationChannelName,
    this.androidStopForegroundOnPause = false,
  });

  /// Android notification-channel identifier for playback notifications.
  final String androidNotificationChannelId;

  /// Human-readable Android notification-channel name.
  final String androidNotificationChannelName;

  /// Whether Android should stop the foreground service when playback pauses.
  final bool androidStopForegroundOnPause;

  /// Converts this package configuration to the underlying audio-service config.
  AudioServiceConfig toAudioServiceConfig() => AudioServiceConfig(
    androidNotificationChannelId: androidNotificationChannelId,
    androidNotificationChannelName: androidNotificationChannelName,
    androidStopForegroundOnPause: androidStopForegroundOnPause,
  );
}
