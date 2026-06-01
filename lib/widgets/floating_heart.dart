import 'package:flutter/material.dart';

class FloatingHeart extends StatefulWidget {
  const FloatingHeart({super.key});

  @override
  State<FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<FloatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> moveUp;
  late Animation<double> fadeOut;
  late Animation<double> scaleUp;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    moveUp = Tween<double>(
      begin: 0,
      end: -90,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    fadeOut = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    scaleUp = Tween<double>(
      begin: 0.7,
      end: 1.35,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, moveUp.value),
          child: Opacity(
            opacity: fadeOut.value,
            child: Transform.scale(
              scale: scaleUp.value,
              child: const Text('💖', style: TextStyle(fontSize: 42)),
            ),
          ),
        );
      },
    );
  }
}
