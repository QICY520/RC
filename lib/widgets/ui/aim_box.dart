import 'package:flutter/material.dart';
import 'package:ruanchuang/theme/app_colors.dart';

class AimBox extends StatefulWidget {
  const AimBox({super.key, required this.size});

  final double size;

  @override
  State<AimBox> createState() => _AimBoxState();
}

class _AimBoxState extends State<AimBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.5,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = _controller.value;
        return Opacity(
          opacity: opacity,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _AimPainter(),
          ),
        );
      },
    );
  }
}

class _AimPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double len = 18;
    const double stroke = 3.0;
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Four corners
    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, len), paint);

    canvas.drawLine(Offset(size.width, 0),
        Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0),
        Offset(size.width, len), paint);

    canvas.drawLine(Offset(0, size.height),
        Offset(0, size.height - len), paint);
    canvas.drawLine(Offset(0, size.height),
        Offset(len, size.height), paint);

    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

