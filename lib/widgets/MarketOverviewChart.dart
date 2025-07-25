import 'package:flutter/material.dart';
import 'dart:math' as math;

class MarketOverviewChart extends StatefulWidget {
  final List<double> data;
  final Color primaryColor;
  final double height;

  const MarketOverviewChart({
    Key? key,
    required this.data,
    required this.primaryColor,
    this.height = 200,
  }) : super(key: key);

  @override
  State<MarketOverviewChart> createState() => _MarketOverviewChartState();
}

class _MarketOverviewChartState extends State<MarketOverviewChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.primaryColor.withValues(alpha: 0.1),
            widget.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.primaryColor,
                      widget.primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Market Overview',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '24H Performance Trend',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+2.4%',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: MarketOverviewChartPainter(
                    data: widget.data,
                    color: widget.primaryColor,
                    animationValue: _animation.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MarketOverviewChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double animationValue;

  MarketOverviewChartPainter({
    required this.data,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Find min and max values
    double minValue = data.reduce(math.min);
    double maxValue = data.reduce(math.max);
    
    // Add some padding
    double padding = (maxValue - minValue) * 0.1;
    minValue -= padding;
    maxValue += padding;

    final path = Path();
    final fillPath = Path();
    
    // Calculate animated data length
    int animatedLength = (data.length * animationValue).round();
    if (animatedLength < 2) animatedLength = 2;
    
    // Calculate points
    List<Offset> points = [];
    for (int i = 0; i < animatedLength; i++) {
      double x = (i / (data.length - 1)) * size.width;
      double normalizedValue = (data[i] - minValue) / (maxValue - minValue);
      double y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));
    }

    // Create smooth curve
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      fillPath.moveTo(0, size.height);
      fillPath.lineTo(points[0].dx, points[0].dy);
      
      for (int i = 1; i < points.length; i++) {
        if (i == 1) {
          path.lineTo(points[i].dx, points[i].dy);
          fillPath.lineTo(points[i].dx, points[i].dy);
        } else {
          // Create smooth curves using quadratic bezier
          final cp1x = points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 2;
          final cp1y = points[i - 1].dy;
          final cp2x = points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 2;
          final cp2y = points[i].dy;
          
          path.cubicTo(cp1x, cp1y, cp2x, cp2y, points[i].dx, points[i].dy);
          fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, points[i].dx, points[i].dy);
        }
      }
      
      // Complete the fill path
      if (points.isNotEmpty) {
        fillPath.lineTo(points.last.dx, size.height);
        fillPath.lineTo(0, size.height);
        fillPath.close();
      }
    }

    // Draw the fill area
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw the line
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i += 3) {
      canvas.drawCircle(points[i], 3, pointPaint);
      
      // Draw glow effect
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points[i], 6, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Generate market overview data
class MarketDataGenerator {
  static List<double> generateMarketOverviewData() {
    final random = math.Random();
    List<double> data = [];
    double baseValue = 45000.0; // Starting BTC price
    
    for (int i = 0; i < 24; i++) { // 24 hours of data
      double change = (random.nextDouble() - 0.5) * 2000;
      // Add some trend
      if (i > 18) {
        change += 500; // Upward trend at the end
      }
      baseValue += change;
      data.add(baseValue);
    }
    
    return data;
  }
}
