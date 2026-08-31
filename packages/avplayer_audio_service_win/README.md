# avplayer_audio_service_win

A customized Windows platform implementation for `avplayer_audio_service`.

It registers Windows System Media Transport Controls so media metadata, lock-screen artwork, playback commands, and hardware media keys can be synchronized by `notification_media_session`.

## Installation

```yaml
dependencies:
  avplayer_audio_service: ^0.18.19+1
  avplayer_audio_service_win: ^0.0.3+1
```

`notification_media_session` registers this implementation during Windows media-session initialization.

## Upstream attribution

This package is derived from the upstream `audio_service_win` project by Hemant KArya. The upstream MIT license and copyright notice are retained in [LICENSE](LICENSE). Project-specific changes are listed in [FORK_NOTES.md](FORK_NOTES.md).

## License

MIT. See [LICENSE](LICENSE).
