## 0.2.0

* Add customizable controls support via `NotificationControlsBuilder` and `NotificationSystemActionsBuilder` in `NotificationMediaSessionConfig`.
* Add `NotificationControls` helper class providing pre-built controls and `NotificationControls.custom(...)` factory.
* Add custom action dispatch handling via `NotificationPlaybackGateway.onCustomAction` and `NotificationMediaSessionConfig.onCustomAction`.
* Export `MediaControl`, `MediaAction`, `MediaButton` directly from `notification_media_session.dart`.
* Depend on `avplayer_audio_service: ^0.18.19+2` with bundled default drawable icon resources.
* Add comprehensive unit tests.
* Enhance documentation and usage guide in `README.md`.

## 0.1.2

* Require `avplayer_audio_service_win` 0.0.3+3 or later to include the renamed public Windows C API header directory.

## 0.1.1

* Require `avplayer_audio_service_win` 0.0.3+2 or later to include the renamed Windows CMake plugin target fix.

## 0.1.0

- Initial extraction of the cross-platform notification and system media-session bridge.
- Adds playback snapshots, host playback gateway, audio-handler synchronization, and an Android notification-permission gateway.
