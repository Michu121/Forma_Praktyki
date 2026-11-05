package com.example.silownia_praktyki

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import com.istornz.live_activities.LiveActivityManager

class RestLiveActivityManager(context: Context) : LiveActivityManager(context) {
    private val appContext = context.applicationContext
    private val remoteViews = RemoteViews(
        appContext.packageName,
        R.layout.live_activity,
    )
    private val openAppIntent = PendingIntent.getActivity(
        appContext,
        0,
        Intent(appContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    init {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_NAME,
                "Przerwy treningowe",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Odliczanie czasu przerwy między seriami"
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            val manager = appContext.getSystemService(
                Context.NOTIFICATION_SERVICE,
            ) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>,
    ): Notification {
        val title = data["title"] as? String ?: "PRZERWA"
        val isComplete = data["isComplete"] as? Boolean ?: false
        val endTime = (data["restEndTime"] as? Number)?.toLong()

        remoteViews.setTextViewText(R.id.rest_title, title)
        if (isComplete) {
            remoteViews.setTextViewText(R.id.rest_timer, "Pora na serię")
        } else if (endTime != null && endTime > System.currentTimeMillis()) {
            val base = SystemClock.elapsedRealtime() +
                (endTime - System.currentTimeMillis())
            remoteViews.setChronometer(R.id.rest_timer, base, null, true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                remoteViews.setChronometerCountDown(R.id.rest_timer, true)
            }
        } else {
            remoteViews.setTextViewText(R.id.rest_timer, "00:00")
        }

        return notification
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(if (isComplete) "Pora na serię." else "Do kolejnej serii:")
            .setContentIntent(openAppIntent)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViews)
            .setCustomBigContentView(remoteViews)
            .setOngoing(!isComplete)
            .setAutoCancel(isComplete)
            .setOnlyAlertOnce(event == "update")
            .setPriority(Notification.PRIORITY_LOW)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
    }

    private companion object {
        const val CHANNEL_NAME = "Live Activities"
    }
}
