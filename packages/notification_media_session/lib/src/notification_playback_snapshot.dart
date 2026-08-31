/// An immutable playback-state update published by the host application.
///
/// A snapshot contains the data required to update a platform media session
/// without exposing the host application's player or domain models.
class NotificationPlaybackSnapshot {
  const NotificationPlaybackSnapshot({
    required this.track,
    required this.phase,
    required this.isPlaying,
    required this.isFavorite,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.speed = 1.0,
  });

  /// Metadata for the active track, or `null` when no track is selected.
  final NotificationTrack? track;

  /// The lifecycle state reported by the host player.
  final NotificationPlaybackPhase phase;

  /// Whether the host player is currently advancing playback.
  final bool isPlaying;

  /// Whether the active track is marked as a favorite by the host application.
  final bool isFavorite;

  /// Current playback position.
  final Duration position;

  /// Furthest media position currently available for playback.
  final Duration bufferedPosition;

  /// Playback speed applied by the host player.
  final double speed;
}

/// Metadata displayed by the platform media session for a single track.
class NotificationTrack {
  const NotificationTrack({
    required this.id,
    required this.title,
    required this.duration,
    this.artist,
    this.album,
    this.artworkUri,
    this.artworkHeaders,
  });

  /// Stable identifier for the track.
  final String id;

  /// Display title for the track.
  final String title;

  /// Total track duration.
  final Duration duration;

  /// Optional artist name shown by supported platforms.
  final String? artist;

  /// Optional album title shown by supported platforms.
  final String? album;

  /// Optional local or remote URI for the artwork image.
  final Uri? artworkUri;

  /// HTTP headers required to load [artworkUri] when it is remote.
  final Map<String, String>? artworkHeaders;
}

/// Lifecycle states that can be mapped to an audio-service processing state.
enum NotificationPlaybackPhase {
  /// No media session is active.
  idle,

  /// Media is being opened or prepared.
  loading,

  /// Playback is waiting for additional media data.
  buffering,

  /// Media is ready to play or is paused after preparation.
  ready,

  /// Playback reached the end of the active track.
  completed,

  /// The host player reported an unrecoverable playback error.
  error,
}
