package com.ryanheise.audioservice;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

public class MediaButtonReceiver extends androidx.media.session.MediaButtonReceiver {
    public static final String ACTION_NOTIFICATION_DELETE = "com.ryanheise.audioservice.intent.action.ACTION_NOTIFICATION_DELETE";
    public static final String ACTION_NOTIFICATION_CUSTOM_ACTION = "com.ryanheise.audioservice.intent.action.ACTION_NOTIFICATION_CUSTOM_ACTION";
    public static final String EXTRA_NOTIFICATION_CUSTOM_ACTION_NAME = "com.ryanheise.audioservice.extra.NOTIFICATION_CUSTOM_ACTION_NAME";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent != null
                && ACTION_NOTIFICATION_DELETE.equals(intent.getAction())
                && AudioService.instance != null) {
            AudioService.instance.handleDeleteNotification();
            return;
        }
        if (intent != null
                && ACTION_NOTIFICATION_CUSTOM_ACTION.equals(intent.getAction())
                && AudioService.instance != null) {
            String actionName = intent.getStringExtra(EXTRA_NOTIFICATION_CUSTOM_ACTION_NAME);
            if (actionName != null) {
                Bundle extras = intent.getExtras();
                AudioService.instance.handleNotificationCustomAction(actionName, extras);
            }
            return;
        }
        super.onReceive(context, intent);
    }
}
