import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final List<String> audioUrls;
  final String? sessionTitle;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrls,
    this.sessionTitle,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentChunkIndex = 0;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupPlayer();
  }

  void _setupPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
      
      // Auto-play next chunk when current finishes
      if (state == PlayerState.completed) {
        _playNextChunk();
      }
    });
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (widget.audioUrls.isEmpty) return;
      
      if (_position == Duration.zero && _currentChunkIndex == 0) {
        await _audioPlayer.play(UrlSource(widget.audioUrls[0]));
      } else {
        await _audioPlayer.resume();
      }
    }
  }

  Future<void> _playNextChunk() async {
    if (_currentChunkIndex < widget.audioUrls.length - 1) {
      _currentChunkIndex++;
      await _audioPlayer.play(UrlSource(widget.audioUrls[_currentChunkIndex]));
    } else {
      await _audioPlayer.stop();
      setState(() {
        _position = Duration.zero;
        _currentChunkIndex = 0;
      });
    }
  }

  Future<void> _seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> _changeSpeed(double speed) async {
    await _audioPlayer.setPlaybackRate(speed);
    setState(() => _playbackSpeed = speed);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble() > 0 
                  ? _duration.inSeconds.toDouble() 
                  : 1.0,
              onChanged: (value) {
                _seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
          
          // Time labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: theme.textTheme.bodySmall,
              ),
              if (widget.audioUrls.length > 1)
                Text(
                  'Chunk ${_currentChunkIndex + 1}/${widget.audioUrls.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              Text(
                _formatDuration(_duration),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Speed control
              PopupMenuButton<double>(
                icon: Icon(
                  Icons.speed,
                  color: theme.colorScheme.primary,
                ),
                onSelected: _changeSpeed,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                  const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                  const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Play/Pause button
              IconButton(
                onPressed: widget.audioUrls.isEmpty ? null : _playPause,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 48,
                ),
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(width: 16),
              
              // Speed indicator
              SizedBox(
                width: 40,
                child: Text(
                  '${_playbackSpeed}x',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
