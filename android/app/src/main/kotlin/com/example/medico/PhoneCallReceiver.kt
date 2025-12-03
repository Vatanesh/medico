package com.example.medico

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log

class PhoneCallReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "PhoneCallReceiver"
        const val ACTION_PHONE_CALL_STATE = "com.example.medico.PHONE_CALL_STATE"
        const val EXTRA_CALL_STATE = "call_state"
        const val STATE_CALL_STARTED = "call_started"
        const val STATE_CALL_ENDED = "call_ended"
        
        private var lastState = TelephonyManager.CALL_STATE_IDLE
    }
    
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            return
        }
        
        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
        Log.d(TAG, "Phone state changed: $state")
        
        when (state) {
            TelephonyManager.EXTRA_STATE_RINGING -> {
                // Incoming call is ringing
                if (lastState == TelephonyManager.CALL_STATE_IDLE) {
                    Log.d(TAG, "Incoming call detected - pausing recording")
                    notifyCallStarted(context)
                    lastState = TelephonyManager.CALL_STATE_RINGING
                }
            }
            
            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                // Call is active (answered or outgoing)
                if (lastState == TelephonyManager.CALL_STATE_IDLE) {
                    Log.d(TAG, "Outgoing call detected - pausing recording")
                    notifyCallStarted(context)
                }
                lastState = TelephonyManager.CALL_STATE_OFFHOOK
            }
            
            TelephonyManager.EXTRA_STATE_IDLE -> {
                // Call ended
                if (lastState != TelephonyManager.CALL_STATE_IDLE) {
                    Log.d(TAG, "Call ended - can resume recording")
                    notifyCallEnded(context)
                    lastState = TelephonyManager.CALL_STATE_IDLE
                }
            }
        }
    }
    
    private fun notifyCallStarted(context: Context?) {
        context?.let {
            val intent = Intent(ACTION_PHONE_CALL_STATE).apply {
                putExtra(EXTRA_CALL_STATE, STATE_CALL_STARTED)
                setPackage(it.packageName) // Make broadcast explicit
            }
            it.sendBroadcast(intent)
            Log.d(TAG, "Broadcast sent: CALL_STARTED")
        }
    }
    
    private fun notifyCallEnded(context: Context?) {
        context?.let {
            val intent = Intent(ACTION_PHONE_CALL_STATE).apply {
                putExtra(EXTRA_CALL_STATE, STATE_CALL_ENDED)
                setPackage(it.packageName) // Make broadcast explicit
            }
            it.sendBroadcast(intent)
            Log.d(TAG, "Broadcast sent: CALL_ENDED")
        }
    }
}
