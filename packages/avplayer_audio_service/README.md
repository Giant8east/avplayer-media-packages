# avplayer_audio_service

A customized fork of `audio_service` for the AVPlayer media-session packages.

## Included customization

- Supports selected `MediaControl.custom` actions as native Android notification actions.
- Uses `androidNativeNotificationAction: true` in custom-action extras to opt into that Android behavior.
- Preserves the Android 13 and newer media-control slot behavior required by `notification_media_session`.

## Installation

```yaml
dependencies:
  avplayer_audio_service: ^0.18.19+1
```

Use the public `audio_service` API from this package to create and initialize an `AudioHandler`.

## Companion packages

- `avplayer_audio_service_win` provides the Windows system-media-session implementation.
- `notification_media_session` provides the app-facing playback snapshot and notification bridge.

## Upstream attribution

This package is derived from the upstream `audio_service` project by Ryan Heise and contributors. The upstream MIT license and copyright notice are retained in [LICENSE](LICENSE). Project-specific modifications are listed in [FORK_NOTES.md](FORK_NOTES.md).

## License

MIT. See [LICENSE](LICENSE).
