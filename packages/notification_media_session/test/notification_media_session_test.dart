import 'dart:async';

import 'package:avplayer_audio_service/avplayer_audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notification_media_session/notification_media_session.dart';

class MockNotificationGateway extends NotificationPlaybackGateway {
  final _snapshots = StreamController<NotificationPlaybackSnapshot>.broadcast();
  NotificationPlaybackSnapshot _current = const NotificationPlaybackSnapshot(
    track: null,
    phase: NotificationPlaybackPhase.idle,
    isPlaying: false,
    isFavorite: false,
  );

  bool playCalled = false;
  bool pauseCalled = false;
  bool skipNextCalled = false;
  bool skipPreviousCalled = false;
  bool changeLikeCalled = false;
  Duration? lastSeek;
  String? lastCustomAction;
  Map<String, dynamic>? lastCustomActionExtras;

  @override
  Stream<NotificationPlaybackSnapshot> get snapshots => _snapshots.stream;

  @override
  NotificationPlaybackSnapshot get currentSnapshot => _current;

  void emit(NotificationPlaybackSnapshot snapshot) {
    _current = snapshot;
    _snapshots.add(snapshot);
  }

  @override
  Future<void> play() async => playCalled = true;

  @override
  Future<void> pause() async => pauseCalled = true;

  @override
  Future<void> skipToNext() async => skipNextCalled = true;

  @override
  Future<void> skipToPrevious() async => skipPreviousCalled = true;

  @override
  Future<void> seek(Duration position) async => lastSeek = position;

  @override
  Future<void> changeLike() async => changeLikeCalled = true;

  @override
  Future<void> stop() async => _snapshots.close();

  @override
  Future<dynamic> onCustomAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    lastCustomAction = name;
    lastCustomActionExtras = extras;
    return 'custom_result_$name';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationAudioHandler', () {
    late MockNotificationGateway gateway;
    late NotificationAudioHandler handler;

    setUp(() {
      gateway = MockNotificationGateway();
      handler = NotificationAudioHandler(gateway);
    });

    tearDown(() async {
      await handler.stop();
    });

    test('publishes snapshot to playbackState and mediaItem', () async {
      const track = NotificationTrack(
        id: 'track-1',
        title: 'Song Title',
        artist: 'Artist Name',
        album: 'Album Name',
        duration: Duration(minutes: 3),
      );

      final snapshot = NotificationPlaybackSnapshot(
        track: track,
        phase: NotificationPlaybackPhase.ready,
        isPlaying: true,
        isFavorite: true,
        position: const Duration(seconds: 45),
        bufferedPosition: const Duration(seconds: 90),
      );

      gateway.emit(snapshot);
      await pumpEventQueue();

      expect(handler.mediaItem.value?.id, 'track-1');
      expect(handler.mediaItem.value?.title, 'Song Title');
      expect(handler.playbackState.value.playing, isTrue);
      expect(
        handler.playbackState.value.processingState,
        AudioProcessingState.ready,
      );
      expect(
        handler.playbackState.value.updatePosition,
        const Duration(seconds: 45),
      );
      expect(
        handler.playbackState.value.bufferedPosition,
        const Duration(seconds: 90),
      );

      // Default controls: favorite (favorited), skipPrevious, pause, skipNext
      final controls = handler.playbackState.value.controls;
      expect(controls.length, 4);
      expect(controls[0].androidIcon, 'drawable/ic_notification_favorite');
      expect(controls[1].action, MediaAction.skipToPrevious);
      expect(controls[2].androidIcon, 'drawable/ic_notif_pause_outline');
      expect(controls[3].action, MediaAction.skipToNext);
    });

    test('delegates custom toggle_favorite action to changeLike', () async {
      final result = await handler.customAction(
        NotificationControls.toggleFavoriteAction,
      );
      expect(result, isTrue);
      expect(gateway.changeLikeCalled, isTrue);
    });

    test('delegates other custom actions to gateway.onCustomAction', () async {
      final result = await handler.customAction('speed_up', {'rate': 1.5});
      expect(result, 'custom_result_speed_up');
      expect(gateway.lastCustomAction, 'speed_up');
      expect(gateway.lastCustomActionExtras, {'rate': 1.5});
    });

    test('supports custom controlsBuilder and onCustomAction in config', () async {
      bool configActionCalled = false;
      final customHandler = NotificationAudioHandler(
        gateway,
        config: NotificationMediaSessionConfig(
          androidNotificationChannelId: 'test_ch',
          androidNotificationChannelName: 'Test Channel',
          controlsBuilder: (snapshot) => [
            NotificationControls.rewind,
            snapshot.isPlaying
                ? NotificationControls.pause
                : NotificationControls.play,
            NotificationControls.fastForward,
            NotificationControls.custom(
              name: 'repeat_mode',
              label: 'Toggle Repeat',
              androidIcon: 'drawable/ic_repeat',
            ),
          ],
          onCustomAction: (name, extras) async {
            if (name == 'repeat_mode') {
              configActionCalled = true;
              return 'handled_in_config';
            }
            return null;
          },
        ),
      );

      gateway.emit(
        const NotificationPlaybackSnapshot(
          track: null,
          phase: NotificationPlaybackPhase.ready,
          isPlaying: false,
          isFavorite: false,
        ),
      );
      await pumpEventQueue();

      final controls = customHandler.playbackState.value.controls;
      expect(controls.length, 4);
      expect(controls[0].action, MediaAction.rewind);
      expect(controls[1].androidIcon, 'drawable/ic_notif_play_outline');
      expect(controls[2].action, MediaAction.fastForward);
      expect(controls[3].customAction?.name, 'repeat_mode');
      expect(
        controls[3].customAction?.extras?['androidNativeNotificationAction'],
        isTrue,
      );

      final result = await customHandler.customAction('repeat_mode');
      expect(result, 'handled_in_config');
      expect(configActionCalled, isTrue);

      await customHandler.stop();
    });
  });
}
