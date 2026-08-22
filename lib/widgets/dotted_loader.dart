// lib/widgets/dotted_loader.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DottedLoader extends StatefulWidget {
  final Color color;
  final double size;
  final int dotCount;

  const DottedLoader({
    super.key,
    this.color = AppColors.primaryGreen,
    this.size = 8.0,
    this.dotCount = 3,
  });

  @override
  State<DottedLoader> createState() => _DottedLoaderState();
}

class _DottedLoaderState extends State<DottedLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
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
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.dotCount, (index) {
            final double delay = index / widget.dotCount;
            final double progress = (_controller.value - delay) % 1.0;
            final double scale = (progress < 0.5)
                ? 0.5 + progress
                : 1.5 - progress;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.3),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(
                  alpha: (0.3 + 0.7 * (scale - 0.5)).clamp(0.2, 1.0),
                ),
              ),
              transform: Matrix4.diagonal3Values(scale, scale, 1.0),
            );
          }),
        );
      },
    );
  }
}
