import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScrollingBackgroundComponent extends Component with HasGameRef {
  final double gameWidth;
  final double gameHeight;

  // Fixed background that covers full screen
  late Paint gradientPaint;
  late Paint groundPaint;

  // Parallax layers for depth effect
  final List<_ParallaxLayer> parallaxLayers = [];

  ScrollingBackgroundComponent({
    required this.gameWidth,
    required this.gameHeight,
  }) {
    _initializeBackground();
  }

  void _initializeBackground() {
    // Create full-screen gradient background
    gradientPaint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFFF0F8FF), // Alice blue
              Color(0xFFE0F6FF), // Light blue
              Color(0xFF98FB98), // Pale green
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, gameWidth * 4, gameHeight));

    // Ground/terrain paint
    groundPaint =
        Paint()
          ..color = const Color(0xFF8BC34A)
          ..style = PaintingStyle.fill;
  }

  @override
  void render(Canvas canvas) {
    // Render full-screen background fixed in world coordinates
    _renderFixedBackground(canvas);

    // Render parallax layers
    _renderParallaxLayers(canvas);
  }

  void _renderFixedBackground(Canvas canvas) {
    // FIXED: Full screen background that fills entire frame without margins
    final backgroundRect = Rect.fromLTWH(
      -gameWidth / 2, // Start from world origin
      -gameHeight / 2, // Start from top of world (no margin)
      gameWidth * 6, // Extra wide to cover entire track
      gameHeight * 2, // Extra tall to ensure full coverage
    );

    canvas.drawRect(backgroundRect, gradientPaint);

    // Add some subtle cloud patterns at fixed world positions
    _renderFixedClouds(canvas);
  }

  void _renderFixedClouds(Canvas canvas) {
    final cloudPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;

    // Fixed clouds at absolute world positions (don't move with camera)
    for (int i = 0; i < 15; i++) {
      final x = i * 200.0; // Fixed world position
      final y = 50.0 + (i % 3) * 40.0;

      canvas.drawCircle(Offset(x, y), 25 + (i % 2) * 10, cloudPaint);
      canvas.drawCircle(Offset(x + 20, y), 20 + (i % 2) * 8, cloudPaint);
      canvas.drawCircle(Offset(x - 15, y + 5), 15 + (i % 2) * 5, cloudPaint);
    }
  }

  void _renderParallaxLayers(Canvas canvas) {
    // Get camera position for subtle parallax effect only
    final cameraX = gameRef.camera.viewfinder.position.x;

    for (final layer in parallaxLayers) {
      layer.render(canvas, cameraX, gameWidth);
    }
  }

  void updateBackgroundPosition(double cameraX) {
    // Background is now fixed relative to world coordinates
    // No need to update position as it's handled in render method
  }
}

class _ParallaxLayer {
  final double speed;
  final Color color;
  final List<double> heights;
  final double baseY;
  late Paint paint;

  _ParallaxLayer({
    required this.speed,
    required this.color,
    required this.heights,
    required this.baseY,
  }) {
    paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
  }

  void render(Canvas canvas, double cameraX, double screenWidth) {
    final path = Path();
    final layerOffset = cameraX * speed;
    final segmentWidth = screenWidth / heights.length;

    // Start path
    path.moveTo(cameraX - screenWidth, baseY + heights[0]);

    // Create terrain silhouette
    for (int i = 0; i < heights.length * 3; i++) {
      final heightIndex = i % heights.length;
      final x = (cameraX - screenWidth) + (i * segmentWidth) - layerOffset;
      final y = baseY + heights[heightIndex];

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Close path to bottom of screen
    final endX =
        (cameraX - screenWidth) +
        (heights.length * 3 * segmentWidth) -
        layerOffset;
    path.lineTo(endX, baseY + 600);
    path.lineTo(cameraX - screenWidth, baseY + 200);
    path.close();

    canvas.drawPath(path, paint);
  }
}
