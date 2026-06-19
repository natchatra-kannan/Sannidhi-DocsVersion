import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme.dart';

class AvengerLogo extends StatelessWidget {
  final String valueType;
  final double size;

  const AvengerLogo({
    super.key,
    required this.valueType,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: SannidhiTheme.teal.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: SannidhiTheme.teal.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: CustomPaint(
        painter: _getPainter(valueType),
      ),
    );
  }

  CustomPainter _getPainter(String type) {
    switch (type.toLowerCase()) {
      case 'gratitude':
        return _ArcReactorPainter(); // Iron Man
      case 'pioneering':
        return _CapShieldPainter(); // Captain America
      case 'entrepreneurial':
        return _MjolnirPainter(); // Thor
      case 'growth':
        return _HulkFistPainter(); // Hulk / Bruce Banner
      case 'inclusive':
        return _AvengersAPainter(); // Avengers Collective
      case 'excellence':
        return _EyeOfAgamottoPainter(); // Doctor Strange / Hawkeye
      default:
        return _AvengersAPainter();
    }
  }
}

// 1. Iron Man's Arc Reactor (Gratitude)
class _ArcReactorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paintRing = Paint()
      ..color = SannidhiTheme.teal.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;
    
    final paintCore = Paint()
      ..color = SannidhiTheme.iceBlue
      ..style = PaintingStyle.fill;
    
    final paintGlow = Paint()
      ..color = SannidhiTheme.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;

    // Outer ring
    canvas.drawCircle(center, radius * 0.8, paintRing);
    
    // Core circle
    canvas.drawCircle(center, radius * 0.3, paintCore);
    
    // Glowing spokes (10 sectors)
    final numSpokes = 8;
    for (int i = 0; i < numSpokes; i++) {
      final angle = (i * 2 * math.pi) / numSpokes;
      final start = Offset(
        center.dx + radius * 0.4 * math.cos(angle),
        center.dy + radius * 0.4 * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * 0.7 * math.cos(angle),
        center.dy + radius * 0.7 * math.sin(angle),
      );
      canvas.drawLine(start, end, paintGlow);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Captain America's Shield (Pioneering)
class _CapShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintBlue = Paint()
      ..color = SannidhiTheme.teal
      ..style = PaintingStyle.fill;

    final paintRed = Paint()
      ..color = SannidhiTheme.iceBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12;

    final paintWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Outer Circle
    canvas.drawCircle(center, radius * 0.8, paintRed);
    // Middle Circle (Gap)
    canvas.drawCircle(center, radius * 0.65, Paint()..color = Colors.transparent..style = PaintingStyle.stroke..strokeWidth = size.width * 0.05);
    // Blue Core
    canvas.drawCircle(center, radius * 0.45, paintBlue);

    // Star inside the core
    final starPath = Path();
    final double innerRadius = radius * 0.18;
    final double outerRadius = radius * 0.45;
    final int numPoints = 5;
    final double angleIncrement = math.pi / numPoints;

    for (int i = 0; i < 2 * numPoints; i++) {
      final double r = (i % 2 == 0) ? outerRadius : innerRadius;
      final double angle = i * angleIncrement - math.pi / 2;
      final double x = center.dx + r * math.cos(angle);
      final double y = center.dy + r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, paintWhite);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. Thor's Hammer Mjolnir (Entrepreneurial)
class _MjolnirPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SannidhiTheme.teal
      ..style = PaintingStyle.fill;

    final paintAccent = Paint()
      ..color = SannidhiTheme.iceBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04;

    final width = size.width;
    final height = size.height;

    // Hammer Head Path
    final headPath = Path()
      ..moveTo(width * 0.3, height * 0.3)
      ..lineTo(width * 0.7, height * 0.3)
      ..lineTo(width * 0.75, height * 0.38)
      ..lineTo(width * 0.75, height * 0.52)
      ..lineTo(width * 0.7, height * 0.6)
      ..lineTo(width * 0.3, height * 0.6)
      ..lineTo(width * 0.25, height * 0.52)
      ..lineTo(width * 0.25, height * 0.38)
      ..close();

    canvas.drawPath(headPath, paint);

    // Hammer Handle
    final handlePath = Path()
      ..moveTo(width * 0.47, height * 0.6)
      ..lineTo(width * 0.53, height * 0.6)
      ..lineTo(width * 0.53, height * 0.85)
      ..lineTo(width * 0.47, height * 0.85)
      ..close();

    canvas.drawPath(handlePath, Paint()..color = SannidhiTheme.iceBlue..style = PaintingStyle.fill);

    // Decorative Lines on Head
    canvas.drawLine(Offset(width * 0.3, height * 0.38), Offset(width * 0.7, height * 0.38), paintAccent);
    canvas.drawLine(Offset(width * 0.3, height * 0.52), Offset(width * 0.7, height * 0.52), paintAccent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. Hulk's Fist (Holistic Growth)
class _HulkFistPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SannidhiTheme.teal
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // A stylized vector representation of a rising fist (Hulk-like) or molecular tree
    final fistPath = Path()
      // Wrist
      ..moveTo(w * 0.35, h * 0.8)
      ..lineTo(w * 0.65, h * 0.8)
      ..lineTo(w * 0.65, h * 0.6)
      // Palm / Fist
      ..lineTo(w * 0.75, h * 0.5)
      ..lineTo(w * 0.7, h * 0.35) // knuckle
      ..lineTo(w * 0.6, h * 0.3)
      ..lineTo(w * 0.5, h * 0.35)
      ..lineTo(w * 0.4, h * 0.3)
      ..lineTo(w * 0.25, h * 0.45)
      ..lineTo(w * 0.35, h * 0.6)
      ..close();

    canvas.drawPath(fistPath, paint);

    // Highlight segments
    final highlightPaint = Paint()
      ..color = SannidhiTheme.iceBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.4, h * 0.4), Offset(w * 0.4, h * 0.55), highlightPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.38), Offset(w * 0.5, h * 0.55), highlightPaint);
    canvas.drawLine(Offset(w * 0.6, h * 0.4), Offset(w * 0.6, h * 0.55), highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 5. Classic Avengers "A" Logo (Inclusive)
class _AvengersAPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SannidhiTheme.teal
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Circle base
    final circlePaint = Paint()
      ..color = SannidhiTheme.iceBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08;
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.4, circlePaint);

    // Styled "A" with the iconic arrow extending right
    final aPath = Path()
      // Left leg
      ..moveTo(w * 0.25, h * 0.75)
      ..lineTo(w * 0.43, h * 0.25)
      ..lineTo(w * 0.57, h * 0.25)
      // Right leg
      ..lineTo(w * 0.72, h * 0.75)
      ..lineTo(w * 0.62, h * 0.75)
      ..lineTo(w * 0.55, h * 0.55)
      // Inner bridge
      ..lineTo(w * 0.42, h * 0.55)
      ..lineTo(w * 0.35, h * 0.75)
      ..close();

    canvas.drawPath(aPath, paint);

    // Arrowhead cutout/accent
    final arrowPaint = Paint()
      ..color = SannidhiTheme.teal
      ..style = PaintingStyle.fill;
    
    final arrowPath = Path()
      ..moveTo(w * 0.5, h * 0.55)
      ..lineTo(w * 0.75, h * 0.55)
      ..lineTo(w * 0.7, h * 0.45)
      ..lineTo(w * 0.85, h * 0.55)
      ..lineTo(w * 0.7, h * 0.65)
      ..lineTo(w * 0.75, h * 0.55)
      ..close();
    
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 6. Doctor Strange's Eye of Agamotto (Excellence)
class _EyeOfAgamottoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;

    final paintOuter = Paint()
      ..color = SannidhiTheme.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06;

    final paintCore = Paint()
      ..color = SannidhiTheme.iceBlue
      ..style = PaintingStyle.fill;

    // Eye outline shape
    final eyePath = Path()
      ..moveTo(w * 0.15, size.height / 2)
      ..quadraticBezierTo(w * 0.5, size.height * 0.15, w * 0.85, size.height / 2)
      ..quadraticBezierTo(w * 0.5, size.height * 0.85, w * 0.15, size.height / 2)
      ..close();

    canvas.drawPath(eyePath, paintOuter);

    // Core pupil (Glowing magic symbol)
    canvas.drawCircle(center, w * 0.18, paintCore);

    // Magical radial lines (precision lines)
    final linesPaint = Paint()
      ..color = SannidhiTheme.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03;

    canvas.drawCircle(center, w * 0.25, linesPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
