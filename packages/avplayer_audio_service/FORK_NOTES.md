# Fork Notes

This package is a modified fork of `audio_service`.

## Upstream attribution

- Upstream repository: https://github.com/ryanheise/audio_service
- Upstream license: MIT. The original text remains in [LICENSE](LICENSE).

## Local modifications

- Supports `MediaControl.custom` as a native Android notification action when extras include `androidNativeNotificationAction: true`.
- Routes that notification action through the MediaSession custom-action path.
- Retains this project's Android 13+ media-control slot behavior.

## Published fork identity

- Dart package name: `avplayer_audio_service`.
- Source repository: https://github.com/Giant8east/avplayer-media-packages
- Keep the upstream [LICENSE](LICENSE) intact in every distributed version.
