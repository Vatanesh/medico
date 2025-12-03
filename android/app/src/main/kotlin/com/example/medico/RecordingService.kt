package com.example.medico

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager

class RecordingService : Service() {
    
    companion object {
        private const val TAG = "RecordingService"
        const val CHANNEL_ID = "recording_service_channel"
        const val NOTIFICATION_ID = 1
        const val ACTION_START = "com.example.medico.START"
        const val ACTION_STOP = "com.example.medico.STOP"
        const val ACTION_PAUSE = "com.example.medico.PAUSE"
        const val ACTION_RESUME = "com.example.medico.RESUME"
        
        // Broadcast actions for communication with Flutter
        const val BROADCAST_ACTION = "com.example.medico.RECORDING_ACTION"
        const val EXTRA_ACTION_TYPE = "action_type"
    }

    private var isRecording = false
    private var isPaused = false
    private var pausedByPhoneCall = false
    
    // Broadcast receiver to listen for phone call events
    private val phoneCallReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            Log.d(TAG, "=== Broadcast received in RecordingService ===")
            Log.d(TAG, "Intent action: ${intent?.action}")
            val callState = intent?.getStringExtra(PhoneCallReceiver.EXTRA_CALL_STATE)
            Log.d(TAG, "Phone call state: $callState")
            Log.d(TAG, "Current recording state - isRecording: $isRecording, isPaused: $isPaused")
            
            when (callState) {
                PhoneCallReceiver.STATE_CALL_STARTED -> {
                    Log.d(TAG, "CALL_STARTED event received")
                    if (isRecording) {
                        Log.d(TAG, "Auto-pausing recording due to phone call")
                        pausedByPhoneCall = true
                        isPaused = true
                        isRecording = false
                        updateNotification("Recording Paused (Call)")
                        sendActionBroadcast("pause")
                    } else {
                        Log.d(TAG, "Not recording, ignoring call start")
                    }
                }
                PhoneCallReceiver.STATE_CALL_ENDED -> {
                    Log.d(TAG, "CALL_ENDED event received")
                    if (isPaused && pausedByPhoneCall) {
                        Log.d(TAG, "Auto-resuming recording after phone call")
                        pausedByPhoneCall = false
                        isPaused = false
                        isRecording = true
                        updateNotification("Recording in Progress")
                        sendActionBroadcast("resume")
                    } else {
                        Log.d(TAG, "Not in phone call pause state, ignoring call end (isPaused: $isPaused, pausedByPhoneCall: $pausedByPhoneCall)")
                    }
                }
                else -> {
                    Log.w(TAG, "Unknown call state: $callState")
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        
        // Register broadcast receiver for phone call events
        val filter = IntentFilter(PhoneCallReceiver.ACTION_PHONE_CALL_STATE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(phoneCallReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(phoneCallReceiver, filter)
        }
        Log.d(TAG, "Phone call receiver registered in service")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                isRecording = true
                isPaused = false
                startForegroundService()
            }
            ACTION_PAUSE -> {
                pausedByPhoneCall = false // Clear phone call flag for manual pause
                isPaused = true
                isRecording = false
                updateNotification("Recording Paused")
                sendActionBroadcast("pause")
            }
            ACTION_RESUME -> {
                isPaused = false
                isRecording = true
                updateNotification("Recording in Progress")
                sendActionBroadcast("resume")
            }
            ACTION_STOP -> {
                sendActionBroadcast("stop")
                stopForeground(true)
                stopSelf()
            }
        }
        return START_STICKY
    }
    
    private fun sendActionBroadcast(actionType: String) {
        val intent = Intent(BROADCAST_ACTION).apply {
            putExtra(EXTRA_ACTION_TYPE, actionType)
        }
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
    }

    private fun startForegroundService() {
        val notification = createNotification("Recording in Progress")
        startForeground(NOTIFICATION_ID, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Recording Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps recording active in background"
                setSound(null, null)
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(title: String): Notification {
        val intent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Pause/Resume action
        val pauseResumeAction = if (isRecording) {
            val pauseIntent = Intent(this, RecordingService::class.java).apply {
                action = ACTION_PAUSE
            }
            val pausePendingIntent = PendingIntent.getService(
                this, 1, pauseIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            NotificationCompat.Action(
                android.R.drawable.ic_media_pause,
                "Pause",
                pausePendingIntent
            )
        } else {
            val resumeIntent = Intent(this, RecordingService::class.java).apply {
                action = ACTION_RESUME
            }
            val resumePendingIntent = PendingIntent.getService(
                this, 2, resumeIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            NotificationCompat.Action(
                android.R.drawable.ic_media_play,
                "Resume",
                resumePendingIntent
            )
        }

        // Stop action
        val stopIntent = Intent(this, RecordingService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 3, stopIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val stopAction = NotificationCompat.Action(
            android.R.drawable.ic_delete,
            "Stop",
            stopPendingIntent
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("MediNote")
            .setContentText(title)
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .addAction(pauseResumeAction)
            .addAction(stopAction)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }

    private fun updateNotification(title: String) {
        val notification = createNotification(title)
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(NOTIFICATION_ID, notification)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        isRecording = false
        isPaused = false
        pausedByPhoneCall = false
        
        // Unregister phone call receiver
        try {
            unregisterReceiver(phoneCallReceiver)
            Log.d(TAG, "Phone call receiver unregistered")
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering phone call receiver: ${e.message}")
        }
    }
}
