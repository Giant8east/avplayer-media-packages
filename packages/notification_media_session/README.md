# notification_media_session

A cross-platform Flutter bridge that synchronizes your app's playback state with system media sessions, notification cards, and lock-screen controls.

- 📱 **Android**: Full support for Android Media Notification, lock screen controls, and Android 13+ media card actions (including custom native actions like favorite/repeat).
- 💻 **Windows**: Integrates with Windows System Media Transport Controls (SMTC) for native volume overlay and taskbar controls.
- 🎯 **Clean Architecture**: Decoupled from any specific player library through the Gateway & Snapshot pattern.
- 🎨 **Customizable & Built-in Resources**: Default vector drawables are pre-bundled, and buttons/actions are fully customizable.

---

## 1. Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  notification_media_session: ^0.2.0
```

---

## 2. Platform Setup

### Android Setup

#### A. Declare Permissions & Services (`android/app/src/main/AndroidManifest.xml`)

Add the required permissions and service declarations inside your `AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions required for foreground playback and notification -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application ...>
        <!-- AudioService declaration -->
        <service
            android:name="com.ryanheise.audioservice.AudioService"
            android:foregroundServiceType="mediaPlayback"
            android:exported="true">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService" />
            </intent-filter>
        </service>

        <!-- Media button receiver for hardware keys and headsets -->
        <receiver
            android:name="com.ryanheise.audioservice.MediaButtonReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON" />
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

#### B. Built-in Android Drawables & Custom Icons

The package **automatically bundles default vector icons** for Android media notification cards:
- `drawable/ic_notification_favorite` (Heart filled)
- `drawable/ic_notification_favorite_border` (Heart outline)
- `drawable/ic_notif_prev_outline` (Previous track)
- `drawable/ic_notif_play_outline` (Play)
- `drawable/ic_notif_pause_outline` (Pause)
- `drawable/ic_notif_next_outline` (Next track)
- `drawable/ic_notif_placeholder` (Placeholder/Stop)
- `drawable/ic_default_artwork` (Default album cover)

> **Adding New / Custom Icons**:
> You can add any custom vector drawable (`.xml`) or PNG file into your app's `android/app/src/main/res/drawable/` directory (e.g. `drawable/ic_repeat`), and reference it directly in custom media controls.

#### C. Request Notification Permission (Android 13+)

On Android 13 (API 33) and above, request the notification permission at app startup:

```dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
}
```

---

## 3. Quick Start

### Step 1: Implement `NotificationPlaybackGateway`

Implement `NotificationPlaybackGateway` to bridge your audio player / ViewModel with the notification session:

```dart
import 'dart:async';
import 'package:notification_media_session/notification_media_session.dart';

class MyPlayerNotificationGateway extends NotificationPlaybackGateway {
  final _snapshots = StreamController<NotificationPlaybackSnapshot>.broadcast();
  NotificationPlaybackSnapshot _current = const NotificationPlaybackSnapshot(
    track: null,
    phase: NotificationPlaybackPhase.idle,
    isPlaying: false,
    isFavorite: false,
  );

  @override
  Stream<NotificationPlaybackSnapshot> get snapshots => _snapshots.stream;

  @override
  NotificationPlaybackSnapshot get currentSnapshot => _current;

  /// Call this method whenever player state, track, or position changes.
  void updateState({
    required NotificationTrack? track,
    required bool isPlaying,
    required bool isFavorite,
    required Duration position,
    required Duration bufferedPosition,
  }) {
    _current = NotificationPlaybackSnapshot(
      track: track,
      phase: isPlaying ? NotificationPlaybackPhase.ready : NotificationPlaybackPhase.idle,
      isPlaying: isPlaying,
      isFavorite: isFavorite,
      position: position,
      bufferedPosition: bufferedPosition,
    );
    _snapshots.add(_current);
  }

  // Handle standard platform control commands
  @override
  Future<void> play() async => myPlayer.play();

  @override
  Future<void> pause() async => myPlayer.pause();

  @override
  Future<void> skipToNext() async => myPlayer.next();

  @override
  Future<void> skipToPrevious() async => myPlayer.previous();

  @override
  Future<void> seek(Duration position) async => myPlayer.seek(position);

  @override
  Future<void> changeLike() async => toggleFavorite();

  @override
  Future<void> stop() async => myPlayer.stop();

  // Optional: handle custom actions
  @override
  Future<dynamic> onCustomAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'my_custom_action') {
      // Execute custom action logic
      return true;
    }
    return null;
  }
}
```

### Step 2: Initialize the Notification Media Session

Initialize the bridge during application startup (e.g., in `main()`):

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final gateway = MyPlayerNotificationGateway();

  final handler = await initializeNotificationMediaSession(
    gateway,
    config: const NotificationMediaSessionConfig(
      androidNotificationChannelId: 'com.example.app.playback',
      androidNotificationChannelName: 'Media Playback',
      androidStopForegroundOnPause: false,
    ),
  );

  runApp(const MyApp());
}
```

---

## 4. Customizing Media Card Buttons & Actions

By default, the notification card displays: `[Favorite, Previous, Play/Pause, Next]`.

You can customize the button layout, add new Android icons, and handle custom actions by specifying `controlsBuilder` and `onCustomAction` in `NotificationMediaSessionConfig`.

### Example: Custom Controls with Rewind, Fast Forward, and Custom Repeat Action

```dart
final handler = await initializeNotificationMediaSession(
  gateway,
  config: NotificationMediaSessionConfig(
    androidNotificationChannelId: 'com.example.app.playback',
    androidNotificationChannelName: 'Media Playback',
    // Custom button layout:
    controlsBuilder: (snapshot) => [
      NotificationControls.rewind,
      snapshot.isPlaying ? NotificationControls.pause : NotificationControls.play,
      NotificationControls.fastForward,
      // Custom action with custom/built-in Android drawable
      NotificationControls.custom(
        name: 'toggle_repeat',
        label: 'Repeat Mode',
        androidIcon: 'drawable/ic_repeat', // Your custom drawable in android/app/src/main/res/drawable/
      ),
    ],
    // Handle custom action:
    onCustomAction: (name, extras) async {
      if (name == 'toggle_repeat') {
        // Toggle player repeat mode
        return true;
      }
      return null;
    },
  ),
);
```

### Pre-built `NotificationControls`

The package provides standard controls ready to use:
- `NotificationControls.favorite` & `NotificationControls.favoriteBorder`
- `NotificationControls.skipPrevious` & `NotificationControls.skipNext`
- `NotificationControls.play` & `NotificationControls.pause`
- `NotificationControls.stop`
- `NotificationControls.rewind` & `NotificationControls.fastForward`
- `NotificationControls.custom(...)` (Factory to construct custom action buttons with native Android 13+ support)

---

## 5. API Reference

### `NotificationTrack`
- `id`: Stable track identifier.
- `title`: Track title.
- `duration`: Track duration.
- `artist`: Artist name (optional).
- `album`: Album title (optional).
- `artworkUri`: Remote URL or local `file://` / `android.resource://` URI for artwork.
- `artworkHeaders`: HTTP headers for authenticated artwork image loading.

### `NotificationPlaybackSnapshot`
- `track`: Active `NotificationTrack?`.
- `phase`: Playback lifecycle (`NotificationPlaybackPhase.ready`, `loading`, `buffering`, etc.).
- `isPlaying`: Boolean indicating playback state.
- `isFavorite`: Boolean indicating favorite state.
- `position`: Current playback position `Duration`.
- `bufferedPosition`: Buffered playback position `Duration`.
- `speed`: Playback rate (defaults to `1.0`).

---

## License

MIT. See [LICENSE](LICENSE).
