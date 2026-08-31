# notification_media_session

A Flutter bridge that publishes application playback state to system media sessions through `avplayer_audio_service`.

## What the host provides

The host application implements `NotificationPlaybackGateway`. It owns player commands, queue navigation, favorite behavior, metadata mapping, artwork URLs, authentication headers, and fallback artwork.

## Initialization

```dart
await initializeNotificationMediaSession(
  gateway,
  config: const NotificationMediaSessionConfig(
    androidNotificationChannelId: 'com.example.player.playback',
    androidNotificationChannelName: 'Audio playback',
    androidStopForegroundOnPause: false,
  ),
);
```

Call `PlatformNotificationPermissionGateway().requestIfNeeded()` from the host app after its first frame when Android notification permission support is configured.

## Android host requirements

The host application must declare notification and media-playback foreground-service permissions, register the service and receiver required by `avplayer_audio_service`, and provide any Android drawable resources referenced by its notification controls.

## Publishing

This repository intentionally keeps `publish_to: none` and local `path` dependencies while `avplayer_audio_service` and `avplayer_audio_service_win` are local. Follow [PUBLISHING.md](PUBLISHING.md) after those forks have been published.

## License

MIT. See [LICENSE](LICENSE).
