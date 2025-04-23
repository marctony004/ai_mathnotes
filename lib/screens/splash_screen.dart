// ================================
// 📦 PATCH 3: Radial Orbit Shuffle with Fade Out
// ================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

const List<String> mathSymbols = [
  "÷", "×", "√", "π", "∑", "∫", "≈", "Δ", "∞", "∇", "∂",
  "f(x)", "log", "ln", "e", "lim", "θ", "∛", "≠", "≤", "≥"
];

class OrbitSplash extends StatefulWidget {
  const OrbitSplash({super.key});

  @override
  State<OrbitSplash> createState() => _OrbitSplashState();
}

class _OrbitSplashState extends State<OrbitSplash> with TickerProviderStateMixin {
  late Timer _navigationTimer;
  late AnimationController _fadeController;
  late List<String> _currentSymbols;
  late Timer _shuffleTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _currentSymbols = List.generate(8, (_) => mathSymbols[_random.nextInt(mathSymbols.length)]);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _shuffleTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      setState(() {
        _currentSymbols = List.generate(8, (_) => mathSymbols[_random.nextInt(mathSymbols.length)]);
      });
    });

    _navigationTimer = Timer(const Duration(seconds: 4), () {
      _shuffleTimer.cancel();
      _fadeController.forward().then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      });
    });
  }

  @override
  void dispose() {
    _shuffleTimer.cancel();
    _navigationTimer.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCF2ED),
      body: Center(
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(_fadeController),
          child: SizedBox(
            width: 360,
            height: 360,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      "Math",
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: Colors.teal,
        fontFamily: 'PatrickHand', // Make sure this font is added in pubspec.yaml
      ),
    ),
    Container(
      width: 60,
      height: 2,
      color: Colors.teal,
    ),
    Text(
  "Qiz",
  style: TextStyle(
    fontFamily: 'PatrickHand',
    fontSize: 40,
    color: Colors.teal,
  ),
)

  ],
),

                ..._buildOrbitSymbols(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOrbitSymbols() {
    final double radius = 110;
    final List<Widget> orbitWidgets = [];
    for (int i = 0; i < _currentSymbols.length; i++) {
      final angle = i * (360 / _currentSymbols.length) * pi / 180;
      final x = radius * cos(angle);
      final y = radius * sin(angle);
      orbitWidgets.add(
        Positioned(
          left: 180 + x,
          top: 180 + y,
          child: Text(
            _currentSymbols[i],
            style: const TextStyle(fontSize: 22, color: Colors.teal, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return orbitWidgets;
  }
}