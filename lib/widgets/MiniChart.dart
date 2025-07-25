import 'package:flutter/material.dart';
import 'dart:math' as math;

class MiniChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double width;
  final double height;
  final bool isPositive;

  const MiniChart({
    Key? key,
    required this.data,
    required this.color,
    this.width = 80,
    this.height = 40,
    this.isPositive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        width: width,
        height: height,
        child: Center(
          child: Icon(
            Icons.show_chart,
            color: color.withValues(alpha: 0.5),
            size: 20,
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      child: CustomPaint(
        painter: MiniChartPainter(
          data: data,
          color: color,
          isPositive: isPositive,
        ),
        size: Size(width, height),
      ),
    );
  }
}

class MiniChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final bool isPositive;

  MiniChartPainter({
    required this.data,
    required this.color,
    required this.isPositive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Find min and max values
    double minValue = data.reduce(math.min);
    double maxValue = data.reduce(math.max);
    
    // Add some padding to avoid flat lines
    if (minValue == maxValue) {
      minValue -= 0.1;
      maxValue += 0.1;
    }

    final path = Path();
    final fillPath = Path();
    
    // Calculate points
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      double x = (i / (data.length - 1)) * size.width;
      double normalizedValue = (data[i] - minValue) / (maxValue - minValue);
      double y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));
    }

    // Create the line path
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      fillPath.moveTo(points[0].dx, size.height);
      fillPath.lineTo(points[0].dx, points[0].dy);
      
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
        fillPath.lineTo(points[i].dx, points[i].dy);
      }
      
      // Complete the fill path
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();
    }

    // Draw the fill area
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw the line
    canvas.drawPath(path, paint);

    // Add gradient effect
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Generate sample data for demonstration
class ChartDataGenerator {
  static List<double> generateSampleData({bool isPositive = true, int points = 20}) {
    final random = math.Random();
    List<double> data = [];
    double baseValue = 100.0;
    
    for (int i = 0; i < points; i++) {
      double change = (random.nextDouble() - 0.5) * 10;
      if (isPositive && i > points * 0.7) {
        change = change.abs(); // Make it trend upward
      } else if (!isPositive && i > points * 0.7) {
        change = -change.abs(); // Make it trend downward
      }
      
      baseValue += change;
      data.add(baseValue);
    }
    
    return data;
  }
}
