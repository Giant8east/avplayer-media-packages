# Publishing Checklist

## Replace before the first release

1. In [LICENSE](LICENSE), replace `[YOUR_NAME_OR_ORGANIZATION]` with the legal owner of this package.
2. In `pubspec.yaml`, add your `repository`, `homepage`, and `issue_tracker` URLs.
3. Publish `avplayer_audio_service` and `avplayer_audio_service_win` first.
4. Replace `path` dependencies in `pubspec.yaml` with hosted version constraints for those published forks.
5. Remove `publish_to: none` only when the dependency graph is publishable.

## Verify

Run these commands from `packages/notification_media_session`:

```powershell
flutter pub get
flutter analyze
flutter pub publish --dry-run
```

Do not publish until the dry run completes without dependency or package-layout errors.
