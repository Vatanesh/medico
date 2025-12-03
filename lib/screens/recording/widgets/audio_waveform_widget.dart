import 'package:flutter/material.dart';

class AudioWaveformWidget extends StatelessWidget {
  final List<double> amplitudeHistory;
  final Color waveColor;
  final double strokeWidth;

  const AudioWaveformWidget({
    super.key,
    required this.amplitudeHistory,
    this.waveColor = Colors.red,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WaveformPainter(
        amplitudes: amplitudeHistory,
        color: waveColor,
        strokeWidth: strokeWidth,
      ),
      size: Size.infinite,
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;
  final double strokeWidth;

  _WaveformPainter({
    required this.amplitudes,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final midY = height / 2;

    // Calculate spacing based on max history length (100)
    // We want the newest data on the right
    final spacing = width / 100; 
    
    // Start drawing from the right side
    double currentX = width;

    for (int i = amplitudes.length - 1; i >= 0; i--) {
      final amplitude = amplitudes[i];
      // Scale amplitude to height (max amplitude is 1.0)
      final waveHeight = amplitude * height;
      
      path.moveTo(currentX, midY - waveHeight / 2);
      path.lineTo(currentX, midY + waveHeight / 2);

      currentX -= spacing;
      
      // Stop if we go off screen
      if (currentX < 0) break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes ||
           oldDelegate.color != color;
  }
}
