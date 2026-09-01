import 'package:avplayer_audio_service/avplayer_audio_service.dart';
import 'notification_playback_snapshot.dart';

/// Predefined and customizable notification media controls.
class NotificationControls {
  const NotificationControls._();

  /// Action name for toggling favorite state.
  static const String toggleFavoriteAction = 'toggle_favorite';

  /// Predefined Android custom action that removes the active track from favorites.
  static final MediaControl favorite = MediaControl.custom(
    androidIcon: 'drawable/ic_notification_favorite',
    label: 'Remove from favorites',
    name: toggleFavoriteAction,
    extras: const {'androidNativeNotificationAction': true},
  );

  /// Predefined Android custom action that adds the active track to favorites.
  static final MediaControl favoriteBorder = MediaControl.custom(
    androidIcon: 'drawable/ic_notification_favorite_border',
    label: 'Add to favorites',
    name: toggleFavoriteAction,
    extras: const {'androidNativeNotificationAction': true},
  );

  /// Predefined previous track control.
  static const MediaControl skipPrevious = MediaControl(
    androidIcon: 'drawable/ic_notif_prev_outline',
    label: 'Previous',
    action: MediaAction.skipToPrevious,
  );

  /// Predefined play control.
  static const MediaControl play = MediaControl(
    androidIcon: 'drawable/ic_notif_play_outline',
    label: 'Play',
    action: MediaAction.playPause,
  );

  /// Predefined pause control.
  static const MediaControl pause = MediaControl(
    androidIcon: 'drawable/ic_notif_pause_outline',
    label: 'Pause',
    action: MediaAction.playPause,
  );

  /// Predefined next track control.
  static const MediaControl skipNext = MediaControl(
    androidIcon: 'drawable/ic_notif_next_outline',
    label: 'Next',
    action: MediaAction.skipToNext,
  );

  /// Predefined stop control.
  static const MediaControl stop = MediaControl(
    androidIcon: 'drawable/ic_notif_placeholder',
    label: 'Stop',
    action: MediaAction.stop,
  );

  /// Predefined rewind control.
  static const MediaControl rewind = MediaControl(
    androidIcon: 'drawable/ic_notif_prev_outline',
    label: 'Rewind',
    action: MediaAction.rewind,
  );

  /// Predefined fast forward control.
  static const MediaControl fastForward = MediaControl(
    androidIcon: 'drawable/ic_notif_next_outline',
    label: 'Fast forward',
    action: MediaAction.fastForward,
  );

  /// Creates a custom media control with native Android notification action support.
  ///
  /// - [name]: Action identifier dispatched to [NotificationPlaybackGateway.onCustomAction]
  ///   or [NotificationMediaSessionConfig.onCustomAction].
  /// - [label]: Accessibility and tooltip text.
  /// - [androidIcon]: Android drawable resource path (e.g. `drawable/ic_custom` or built-in drawables).
  /// - [androidNativeNotificationAction]: If `true` (default), marks this action to be displayed
  ///   as a native notification action on Android 13+ media card.
  /// - [extras]: Additional parameters to pass along with the custom action.
  static MediaControl custom({
    required String name,
    required String label,
    required String androidIcon,
    Map<String, dynamic>? extras,
    bool androidNativeNotificationAction = true,
  }) =>
      MediaControl.custom(
        name: name,
        label: label,
        androidIcon: androidIcon,
        extras: {
          if (androidNativeNotificationAction)
            'androidNativeNotificationAction': true,
          ...?extras,
        },
      );

  /// Default notification controls generator matching the standard player layout:
  /// `[Favorite, Previous, Play/Pause, Next]`.
  static List<MediaControl> defaultControls(
    NotificationPlaybackSnapshot snapshot,
  ) => [
    snapshot.isFavorite ? favorite : favoriteBorder,
    skipPrevious,
    snapshot.isPlaying ? pause : play,
    skipNext,
  ];
}
