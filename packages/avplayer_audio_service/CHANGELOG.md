## 0.18.19+3

* Bundle transparent placeholder drawable resource (`ic_notif_spacer`) directly in the Android library package to support 5-slot balanced notification layouts.

## 0.18.19+2

* Bundle default media notification drawable resources (`ic_notification_favorite`, `ic_notification_favorite_border`, `ic_notif_prev_outline`, `ic_notif_play_outline`, `ic_notif_pause_outline`, `ic_notif_next_outline`, `ic_notif_placeholder`, `ic_default_artwork`) directly in the Android library package.

## 0.18.19+1

* First AVPlayer fork release based on upstream `audio_service` 0.18.19.
* Add native Android notification support for opted-in custom media actions.
* Route native notification custom actions through the MediaSession custom-action callback.

## 0.18.19

* Support AGP 9.
* Migrate Android build files to .kts

## 0.18.18

* Fix setPlaybackState entitlement issue on iOS.
* Fix Android stopForeground deprecation warning.
* Bump compile/target SDK to 35 on Android.
* Bump minSdk to 19 on Android.
* bump AGP to 8.5.2.

## 0.18.17

* Add support for SwiftPM.

## 0.18.16

* Support MPNowPlayingInfoPropertyIsLiveStream on IOS (@MuradSh, @celsoft).

## 0.18.15

* Add deep link support for FlutterFragmentActivity (@jan-milovanovic).
