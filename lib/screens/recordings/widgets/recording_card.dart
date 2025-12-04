import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/session.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../l10n/app_localizations.dart';
import 'audio_player_widget.dart';

class RecordingCard extends StatelessWidget {
  final RecordingSession recording;

  const RecordingCard({
    super.key,
    required this.recording,
  });

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'recording':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'failed':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getLocalizedStatus(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'completed':
        return l10n.completed;
      case 'recording':
        return l10n.recording;
      case 'processing':
        return l10n.processing;
      case 'failed':
        return l10n.failed;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    // Get all audio URLs from chunks
    // If publicUrl is available, use it. Otherwise, construct from gcsPath
    final audioUrls = recording.chunks.map((chunk) {
      if (chunk.publicUrl != null && chunk.publicUrl!.isNotEmpty) {
        return chunk.publicUrl!;
      } else if (chunk.gcsPath.isNotEmpty) {
        // Extract filename from gcsPath (e.g., "session_id/chunk_0.wav" -> "chunk_0.wav")
        final filename = chunk.gcsPath.split('/').last;
        return ApiEndpoints.storagePublic(recording.id, filename);
      }
      return null;
    })
    .where((url) => url != null)
    .cast<String>()
    .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.mic_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recording.sessionTitle ?? 'Medical Consultation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(recording.startTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(recording.status, colorScheme)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(recording.status, colorScheme),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getLocalizedStatus(recording.status, l10n).toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(recording.status, colorScheme),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Metadata
            Row(
              children: [
                if (recording.duration != null) ...[
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    recording.duration!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(
                  Icons.audio_file_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${recording.totalChunks} ${l10n.chunks}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            
            if (recording.sessionSummary != null) ...[
              const SizedBox(height: 12),
              Text(
                recording.sessionSummary!,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Audio player
            if (audioUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              AudioPlayerWidget(
                audioUrls: audioUrls,
                sessionTitle: recording.sessionTitle,
              ),
            ] else ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.noAudioAvailable,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}