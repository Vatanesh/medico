package com.example.medico

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.medico/recording_service"
    private var methodChannel: MethodChannel? = null

    
    private val recordingActionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val actionType = intent?.getStringExtra(RecordingService.EXTRA_ACTION_TYPE)
            actionType?.let {
                // Invoke Flutter method to handle the action
                methodChannel?.invokeMethod("onRecordingAction", mapOf("action" to it))
            }
        }
    }
    
    private val phoneCallReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val callState = intent?.getStringExtra(PhoneCallReceiver.EXTRA_CALL_STATE)
            callState?.let {
                // Invoke Flutter method to handle phone call state
                methodChannel?.invokeMethod("onPhoneCallStateChanged", mapOf("state" to it))
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "startService" -> {
                        startRecordingService()
                        result.success(true)
                    }
                    "stopService" -> {
                        stopRecordingService()
                        result.success(true)
                    }
                    "pauseService" -> {
                        pauseRecordingService()
                        result.success(true)
                    }
                    "resumeService" -> {
                        resumeRecordingService()
                        result.success(true)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
        }
        
        // Register broadcast receiver for recording actions
        val filter = IntentFilter(RecordingService.BROADCAST_ACTION)
        LocalBroadcastManager.getInstance(this).registerReceiver(recordingActionReceiver, filter)
        
        // Register broadcast receiver for phone call state
        val phoneFilter = IntentFilter(PhoneCallReceiver.ACTION_PHONE_CALL_STATE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(phoneCallReceiver, phoneFilter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(phoneCallReceiver, phoneFilter)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Unregister broadcast receivers
        try {
            LocalBroadcastManager.getInstance(this).unregisterReceiver(recordingActionReceiver)
        } catch (e: Exception) {
            // Receiver not registered
        }
        try {
            unregisterReceiver(phoneCallReceiver)
        } catch (e: Exception) {
            // Receiver not registered
        }
    }

    private fun startRecordingService() {
        val intent = Intent(this, RecordingService::class.java).apply {
            action = RecordingService.ACTION_START
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopRecordingService() {
        val intent = Intent(this, RecordingService::class.java).apply {
            action = RecordingService.ACTION_STOP
        }
        startService(intent)
    }

    private fun pauseRecordingService() {
        val intent = Intent(this, RecordingService::class.java).apply {
            action = RecordingService.ACTION_PAUSE
        }
        startService(intent)
    }

    private fun resumeRecordingService() {
        val intent = Intent(this, RecordingService::class.java).apply {
            action = RecordingService.ACTION_RESUME
        }
        startService(intent)
    }
}
