# avplayer_audio_service

A customized fork of `audio_service` for the AVPlayer media-session packages.

## Included customization

- Supports selected `MediaControl.custom` actions as native Android notification actions.
- Uses `androidNativeNotificationAction: true` in custom-action extras to opt into native Android 13+ notification card actions.
- Bundles default media notification vector drawables (`ic_notification_favorite`, `ic_notification_favorite_border`, `ic_notif_prev_outline`, `ic_notif_play_outline`, `ic_notif_pause_outline`, `ic_notif_next_outline`, `ic_notif_placeholder`, `ic_notif_spacer`, `ic_default_artwork`).
- Preserves the Android 13 and newer media-control slot behavior required by `notification_media_session`.

## Installation

```yaml
dependencies:
  avplayer_audio_service: ^0.18.19+3
```

Use the public `audio_service` API from this package to create and initialize an `AudioHandler`.

## Companion packages

- `avplayer_audio_service_win` provides the Windows system-media-session implementation.
- `notification_media_session` provides the app-facing playback snapshot and notification bridge.

## Upstream attribution

This package is derived from the upstream `audio_service` project by Ryan Heise and contributors. The upstream MIT license and copyright notice are retained in [LICENSE](LICENSE). Project-specific modifications are listed in [FORK_NOTES.md](FORK_NOTES.md).

## License

MIT. See [LICENSE](LICENSE).
