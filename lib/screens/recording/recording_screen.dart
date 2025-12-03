import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/patient.dart';
import '../../providers/recording_provider.dart';
import '../../services/native_recording_service.dart';
import 'widgets/audio_waveform_widget.dart';

class RecordingScreen extends StatefulWidget {
  final Patient patient;
  final String userId;

  const RecordingScreen({
    super.key,
    required this.patient,
    required this.userId,
  });

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recordingProvider = Provider.of<RecordingProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.name),
        actions: [
          if ((recordingProvider.isRecording || recordingProvider.isPaused) && 
              recordingProvider.currentSession?.patientId == widget.patient.id)
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: () => _showStopConfirmation(context, recordingProvider),
              tooltip: l10n.stopRecording,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Network status
              if (!recordingProvider.isOnline)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, color: colorScheme.onErrorContainer, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.networkOffline,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ],
                  ),
                ),

              const Spacer(flex: 1),

              // Hero Timer Display
              Column(
                children: [
                  Text(
                    recordingProvider.formattedDuration,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                      fontSize: 72,
                      fontFeatures: [const FontFeature.tabularFigures()],
                      color: recordingProvider.isRecording
                          ? colorScheme.error
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: recordingProvider.isRecording 
                          ? colorScheme.errorContainer 
                          : colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (recordingProvider.isRecording)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          recordingProvider.isRecording
                              ? l10n.recording
                              : recordingProvider.isPaused
                                  ? l10n.paused
                                  : l10n.ready,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: recordingProvider.isRecording 
                                ? colorScheme.onErrorContainer 
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Waveform & Gain Card
              if (recordingProvider.isRecording && 
                  recordingProvider.currentSession?.patientId == widget.patient.id) ...[
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Waveform
                        SizedBox(
                          height: 80,
                          width: double.infinity,
                          child: AudioWaveformWidget(
                            amplitudeHistory: recordingProvider.amplitudeHistory,
                            waveColor: colorScheme.primary,
                            strokeWidth: 3.0,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Gain Control
                        Row(
                          children: [
                            Icon(Icons.mic, size: 20, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                ),
                                child: Slider(
                                  value: recordingProvider.gain,
                                  min: 0.0,
                                  max: 4.0,
                                  divisions: 40,
                                  label: '${recordingProvider.gain.toStringAsFixed(1)}x',
                                  onChanged: (value) => recordingProvider.setGain(value),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${recordingProvider.gain.toStringAsFixed(1)}x',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const Spacer(flex: 2),

              // Control Buttons
              if (!recordingProvider.isRecording && !recordingProvider.isPaused || 
                  recordingProvider.currentSession?.patientId != widget.patient.id)
                SizedBox(
                  width: double.infinity,
                  height: 72,
                  child: FilledButton.icon(
                    onPressed: () => _startRecording(recordingProvider),
                    icon: const Icon(Icons.mic, size: 28),
                    label: Text(
                      l10n.startRecording,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pause/Resume Button
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: IconButton.filledTonal(
                        onPressed: recordingProvider.isRecording
                            ? () => recordingProvider.pauseRecording()
                            : () => recordingProvider.resumeRecording(),
                        icon: Icon(
                          recordingProvider.isRecording
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 40,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceVariant,
                          foregroundColor: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Stop Button
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: IconButton.filled(
                        onPressed: () => _showStopConfirmation(context, recordingProvider),
                        icon: const Icon(Icons.stop_rounded, size: 48),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                        ),
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startRecording(RecordingProvider recordingProvider) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      await recordingProvider.startRecording(
        userId: widget.userId,
        patientId: widget.patient.id,
        patientName: widget.patient.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recordingStarted)),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        
        // Show user-friendly error for notification permission
        if (e.toString().contains('Notification permission')) {
          errorMessage = l10n.notificationPermissionDenied;
        } else if (e.toString().contains('Microphone permission')) {
          errorMessage = l10n.microphonePermission;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            action: e.toString().contains('permission')
                ? SnackBarAction(
                    label: l10n.settings,
                    onPressed: () async {
                      // Open app settings
                      await NativeRecordingService.requestNotificationPermission();
                    },
                  )
                : null,
          ),
        );
      }
    }
  }

  Future<void> _showStopConfirmation(
    BuildContext context,
    RecordingProvider recordingProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.stopRecording),
        content: Text(l10n.confirmStopMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.stop),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await recordingProvider.stopRecording();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
