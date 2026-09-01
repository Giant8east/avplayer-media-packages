import 'notification_playback_snapshot.dart';

/// Contract between the host application and the system media-session bridge.
///
/// Implementations publish playback snapshots and execute commands received
/// from platform media controls. Business rules and player-specific behavior
/// remain in the host application.
abstract class NotificationPlaybackGateway {
  /// Emits a snapshot whenever system media-session state may need updating.
  Stream<NotificationPlaybackSnapshot> get snapshots;

  /// Returns the latest snapshot for the initial media-session synchronization.
  NotificationPlaybackSnapshot get currentSnapshot;

  /// Starts or resumes playback.
  Future<void> play();

  /// Pauses playback.
  Future<void> pause();

  /// Selects the next playable item.
  Future<void> skipToNext();

  /// Selects the previous playable item.
  Future<void> skipToPrevious();

  /// Seeks the active item to [position].
  Future<void> seek(Duration position);

  /// Toggles the favorite state of the active item.
  ///
  /// Defaults to a no-op if the host application does not support favorites.
  Future<void> changeLike() async {}

  /// Stops playback and clears host-managed playback state as appropriate.
  Future<void> stop();

  /// Handles custom actions triggered from platform media controls.
  ///
  /// By default, returns `null`. Override this method to handle custom
  /// actions added via [NotificationMediaSessionConfig.controlsBuilder].
  Future<dynamic> onCustomAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async => null;
}
