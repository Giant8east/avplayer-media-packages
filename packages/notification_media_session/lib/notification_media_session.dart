import 'package:avplayer_audio_service/avplayer_audio_service.dart';
import 'package:avplayer_audio_service_win/avplayer_audio_service_win.dart';
import 'package:flutter/foundation.dart';

import 'src/notification_audio_handler.dart';
import 'src/notification_media_session_config.dart';
import 'src/notification_playback_gateway.dart';

export 'package:avplayer_audio_service/avplayer_audio_service.dart'
    show MediaAction, MediaButton, MediaControl;
export 'src/notification_audio_handler.dart';
export 'src/notification_controls.dart';
export 'src/notification_media_session_config.dart';
export 'src/notification_permission_gateway.dart';
export 'src/notification_playback_gateway.dart';
export 'src/notification_playback_snapshot.dart';

/// Initializes the platform media session for the current application process.
///
/// On Windows, registers the bundled media-session implementation before
/// initializing `AudioService`. The returned handler is synchronized with
/// [NotificationPlaybackGateway.currentSnapshot] before this future completes.
Future<NotificationAudioHandler> initializeNotificationMediaSession(
  NotificationPlaybackGateway gateway, {
  required NotificationMediaSessionConfig config,
}) async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    AudioServiceWin.registerWith();
  }

  final handler = await AudioService.init(
    builder: () => NotificationAudioHandler(gateway, config: config),
    config: config.toAudioServiceConfig(),
  );
  await handler.synchronize();
  return handler;
}
