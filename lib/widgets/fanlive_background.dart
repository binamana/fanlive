import 'package:flutter/material.dart';

class FanLiveBackground extends StatelessWidget {
  final Widget child;

  const FanLiveBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF120018),
              Color(0xFF2B0B3F),
              Color(0xFF151022),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
    );
  }
}