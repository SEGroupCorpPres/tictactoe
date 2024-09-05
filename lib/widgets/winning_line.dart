import 'package:flutter/material.dart';

class WinningLinePainter extends CustomPainter {
  final List<List<int>> winningLine;
  final double cellSize;

  WinningLinePainter({required this.winningLine, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (winningLine.isNotEmpty) {
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke;

      // Start and end points of the line
      final start = Offset(
        winningLine[0][1] * cellSize + cellSize / 2,
        winningLine[0][0] * cellSize + cellSize / 2,
      );
      final end = Offset(
        winningLine[2][1] * cellSize + cellSize / 2,
        winningLine[2][0] * cellSize + cellSize / 2,
      );

      // Draw the line
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
