# AVPlayer Media Packages

Flutter packages used by AVPlayer to synchronize application playback with Android notifications, Windows system media controls, and web media sessions.

## Packages

| Package | Purpose |
| --- | --- |
| `avplayer_audio_service` | Customized `audio_service` fork. Adds the Android native-notification custom-action behavior required by this project. |
| `avplayer_audio_service_win` | Windows system-media-session implementation used by the customized audio-service stack. |
| `notification_media_session` | App-facing bridge. It converts host playback snapshots into system media-session state and routes system commands back through a gateway. |

## Dependency direction

```text
Host application
        |
        v
notification_media_session
        |
        +-- avplayer_audio_service
        |
        +-- avplayer_audio_service_win
```

The host application owns player behavior, playlist logic, artwork URLs, authentication headers, fallback artwork, and the implementation of `NotificationPlaybackGateway`.

## Publishing order

1. Publish `avplayer_audio_service`.
2. Publish `avplayer_audio_service_win`.
3. Replace local path dependencies in `notification_media_session` with the published versions.
4. Remove `publish_to: none` from `notification_media_session` and publish it.

Each package has its own README, changelog, and license information. The two fork packages retain their upstream MIT licenses and attribution.
