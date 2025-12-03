import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NativeRecordingService {
  static const platform = MethodChannel('com.example.medico/recording_service');
  
  // Callbacks for recording actions from notification
  static Function()? onPause;
  static Function()? onResume;
  static Function()? onStop;
  
  // Callbacks for phone call interruptions
  static Function()? onPhoneCallStarted;
  static Function()? onPhoneCallEnded;

  /// Initialize the service and set up callback handler
  static void initialize() {
    platform.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle method calls from native side
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onRecordingAction') {
      final action = call.arguments['action'] as String?;
      debugPrint('[NATIVE] Received action from notification: $action');
      
      switch (action) {
        case 'pause':
          onPause?.call();
          break;
        case 'resume':
          onResume?.call();
          break;
        case 'stop':
          onStop?.call();
          break;
      }
    } else if (call.method == 'onPhoneCallStateChanged') {
      final state = call.arguments['state'] as String?;
      debugPrint('[NATIVE] Phone call state changed: $state');
      
      switch (state) {
        case 'call_started':
          onPhoneCallStarted?.call();
          break;
        case 'call_ended':
          onPhoneCallEnded?.call();
          break;
      }
    }
  }

  /// Request notification permission (required for Android 13+)
  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      debugPrint('[NATIVE] Notification permission: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('[NATIVE] Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if notification permission is granted
  static Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('[NATIVE] Error checking notification permission: $e');
      // On Android < 13, this permission doesn't exist, so we return true
      return true;
    }
  }
  
  /// Request phone state permission (required for call detection)
  static Future<bool> requestPhoneStatePermission() async {
    try {
      final status = await Permission.phone.request();
      debugPrint('[NATIVE] Phone state permission: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('[NATIVE] Error requesting phone state permission: $e');
      return false;
    }
  }
  
  /// Check if phone state permission is granted
  static Future<bool> hasPhoneStatePermission() async {
    try {
      final status = await Permission.phone.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('[NATIVE] Error checking phone state permission: $e');
      return false;
    }
  }

  static Future<void> startService() async {
    try {
      await platform.invokeMethod('startService');
      debugPrint('[NATIVE] Service started');
    } on PlatformException catch (e) {
      debugPrint('[NATIVE] Failed to start service: ${e.message}');
      // Don't throw - native service is optional
    } catch (e) {
      debugPrint('[NATIVE] Error: $e');
    }
  }

  static Future<void> stopService() async {
    try {
      await platform.invokeMethod('stopService');
      debugPrint('[NATIVE] Service stopped');
    } on PlatformException catch (e) {
      debugPrint('[NATIVE] Failed to stop service: ${e.message}');
    } catch (e) {
      debugPrint('[NATIVE] Error: $e');
    }
  }

  static Future<void> pauseService() async {
    try {
      await platform.invokeMethod('pauseService');
      debugPrint('[NATIVE] Service paused');
    } on PlatformException catch (e) {
      debugPrint('[NATIVE] Failed to pause service: ${e.message}');
    } catch (e) {
      debugPrint('[NATIVE] Error: $e');
    }
  }

  static Future<void> resumeService() async {
    try {
      await platform.invokeMethod('resumeService');
      debugPrint('[NATIVE] Service resumed');
    } on PlatformException catch (e) {
      debugPrint('[NATIVE] Failed to resume service: ${e.message}');
    } catch (e) {
      debugPrint('[NATIVE] Error: $e');
    }
  }
}
