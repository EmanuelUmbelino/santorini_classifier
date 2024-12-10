import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.amber.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const int gridDivisions = 5;
    double gridSize = size.height < size.width ? size.height : size.width;
    gridSize -= gridSize * 0.05;

    final double left = (size.width - gridSize) / 2;
    final double top = (size.height - gridSize) / 2;
    final double right = left + gridSize;
    final double bottom = top + gridSize;

    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), borderPaint);

    final double cellSize = gridSize / gridDivisions;

    // Desenhar linhas horizontais.
    for (int i = 1; i < gridDivisions; i++) {
      final y = top + (cellSize * i);
      canvas.drawLine(Offset(left, y), Offset(right, y), paint);
    }

    // Desenhar linhas verticais.
    for (int i = 1; i < gridDivisions; i++) {
      final x = left + (cellSize * i);
      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
