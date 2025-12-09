import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/game_constants.dart';

/// Enhanced scrolling background with neon theme
class BackgroundComponent extends Component with HasGameRef {
  final double gameWidth;
  final double gameHeight;

  late Paint gradientPaint;
  late Paint starPaint;

  final List<_Star> stars = [];
  final Random _random = Random();

  BackgroundComponent({required this.gameWidth, required this.gameHeight}) {
    _initializeBackground();
    _generateStars();
  }

  void _initializeBackground() {
    // Neon cyber gradient background
    gradientPaint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [NeonTheme.bgDark, NeonTheme.bgMid, NeonTheme.bgLight],
            stops: [0.0, 0.5, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, gameWidth * 4, gameHeight));

    starPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
  }

  void _generateStars() {
    // Generate random stars across the world
    for (int i = 0; i < 100; i++) {
      stars.add(
        _Star(
          x: _random.nextDouble() * gameWidth * 2,
          y: _random.nextDouble() * gameHeight,
          size: 1 + _random.nextDouble() * 2,
          twinkleSpeed: 0.5 + _random.nextDouble() * 1.5,
          twinkleOffset: _random.nextDouble() * pi * 2,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update star twinkling
    for (final star in stars) {
      star.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    _renderFixedBackground(canvas);
    _renderStars(canvas);
    _renderGrid(canvas);
  }

  void _renderFixedBackground(Canvas canvas) {
    // Full screen background that fills entire frame
    final backgroundRect = Rect.fromLTWH(
      -gameWidth / 2,
      -gameHeight / 2,
      gameWidth * 6,
      gameHeight * 2,
    );

    canvas.drawRect(backgroundRect, gradientPaint);
  }

  void _renderStars(Canvas canvas) {
    for (final star in stars) {
      starPaint.color = Colors.white.withValues(alpha: star.alpha);
      canvas.drawCircle(Offset(star.x, star.y), star.size, starPaint);

      // Add glow for larger stars
      if (star.size > 1.5) {
        final glowPaint =
            Paint()
              ..color = NeonTheme.trackPrimary.withValues(
                alpha: star.alpha * 0.3,
              )
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(star.x, star.y), star.size * 2, glowPaint);
      }
    }
  }

  void _renderGrid(Canvas canvas) {
    // Subtle grid pattern in the background
    final gridPaint =
        Paint()
          ..color = NeonTheme.trackPrimary.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    const gridSize = 100.0;

    // Vertical lines
    for (double x = 0; x < gameWidth * 2; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, gameHeight), gridPaint);
    }

    // Horizontal lines
    for (double y = 0; y < gameHeight; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(gameWidth * 2, y), gridPaint);
    }
  }
}

/// Star with twinkling animation
class _Star {
  final double x;
  final double y;
  final double size;
  final double twinkleSpeed;
  double twinkleOffset;

  double _twinkleTime = 0;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.twinkleOffset,
  });

  void update(double dt) {
    _twinkleTime += dt * twinkleSpeed;
    if (_twinkleTime > pi * 2) {
      _twinkleTime -= pi * 2;
    }
  }

  double get alpha {
    return 0.3 + (sin(_twinkleTime + twinkleOffset) * 0.5 + 0.5) * 0.7;
  }
}
