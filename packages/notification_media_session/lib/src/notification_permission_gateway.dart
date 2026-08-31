import 'package:flutter/services.dart';

/// Requests notification permission when the current platform requires it.
abstract interface class NotificationPermissionGateway {
  /// Requests permission if necessary and returns whether notifications are allowed.
  Future<bool> requestIfNeeded();
}

/// Delegates notification-permission requests to the host Android application.
///
/// The host must register the `notification_media_session/notification_permission`
/// method channel and implement the `requestIfNeeded` method.
class PlatformNotificationPermissionGateway
    implements NotificationPermissionGateway {
  const PlatformNotificationPermissionGateway();

  static const _channel = MethodChannel(
    'notification_media_session/notification_permission',
  );

  @override
  Future<bool> requestIfNeeded() async =>
      await _channel.invokeMethod<bool>('requestIfNeeded') ?? false;
}
