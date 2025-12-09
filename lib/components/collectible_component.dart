import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/game_constants.dart';

/// Type of collectible
enum CollectibleType { coin, star, gem }

/// Base class for collectible items
class CollectibleComponent extends PositionComponent {
  final CollectibleType type;
  final double itemRadius;

  bool isCollected = false;
  double _floatOffset = 0;
  double _rotationAngle = 0;
  final double _floatSpeed = 2.0;
  final double _floatAmplitude = 5.0;
  final double _rotationSpeed = 2.0;

  late Paint itemPaint;
  late Paint glowPaint;
  late Paint sparkPaint;

  CollectibleComponent({
    required Vector2 position,
    required this.type,
    this.itemRadius = 12.0,
  }) {
    this.position = position;
    size = Vector2.all(itemRadius * 2);

    _initializePaints();
  }

  void _initializePaints() {
    final color = getColorForType();

    itemPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    glowPaint =
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    sparkPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill;
  }

  Color getColorForType() {
    switch (type) {
      case CollectibleType.coin:
        return NeonTheme.coinGold;
      case CollectibleType.star:
        return NeonTheme.starWhite;
      case CollectibleType.gem:
        return NeonTheme.gemPurple;
    }
  }

  int get value {
    switch (type) {
      case CollectibleType.coin:
        return GameConfig.coinValue;
      case CollectibleType.star:
        return GameConfig.starValue;
      case CollectibleType.gem:
        return GameConfig.gemValue;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isCollected) return;

    // Floating animation
    _floatOffset += _floatSpeed * dt;
    if (_floatOffset > 2 * pi) {
      _floatOffset -= 2 * pi;
    }

    // Rotation animation
    _rotationAngle += _rotationSpeed * dt;
    if (_rotationAngle > 2 * pi) {
      _rotationAngle -= 2 * pi;
    }
  }

  @override
  void render(Canvas canvas) {
    if (isCollected) return;

    canvas.save();

    // Apply floating offset
    final floatY = sin(_floatOffset) * _floatAmplitude;
    canvas.translate(itemRadius, itemRadius + floatY);
    canvas.rotate(_rotationAngle);

    // Draw glow
    canvas.drawCircle(Offset.zero, itemRadius * 1.5, glowPaint);

    // Draw item based on type
    switch (type) {
      case CollectibleType.coin:
        _drawCoin(canvas);
        break;
      case CollectibleType.star:
        _drawStar(canvas);
        break;
      case CollectibleType.gem:
        _drawGem(canvas);
        break;
    }

    canvas.restore();
  }

  void _drawCoin(Canvas canvas) {
    // Outer circle
    canvas.drawCircle(Offset.zero, itemRadius, itemPaint);

    // Inner circle (darker)
    final innerPaint =
        Paint()
          ..color = NeonTheme.coinGold.withValues(alpha: 0.7)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, itemRadius * 0.7, innerPaint);

    // Highlight
    canvas.drawCircle(
      Offset(-itemRadius * 0.3, -itemRadius * 0.3),
      itemRadius * 0.3,
      sparkPaint,
    );
  }

  void _drawStar(Canvas canvas) {
    final path = Path();
    const points = 5;
    const angleStep = pi * 2 / points;

    for (int i = 0; i < points * 2; i++) {
      final angle = i * angleStep / 2 - pi / 2;
      final radius = i.isEven ? itemRadius : itemRadius * 0.5;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, itemPaint);

    // Center sparkle
    canvas.drawCircle(Offset.zero, itemRadius * 0.2, sparkPaint);
  }

  void _drawGem(Canvas canvas) {
    final path = Path();

    // Create diamond shape
    path.moveTo(0, -itemRadius);
    path.lineTo(itemRadius * 0.6, 0);
    path.lineTo(0, itemRadius);
    path.lineTo(-itemRadius * 0.6, 0);
    path.close();

    canvas.drawPath(path, itemPaint);

    // Add facets
    final facetPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawLine(Offset(0, -itemRadius), Offset(0, itemRadius), facetPaint);
    canvas.drawLine(
      Offset(-itemRadius * 0.6, 0),
      Offset(itemRadius * 0.6, 0),
      facetPaint,
    );

    // Highlight
    canvas.drawCircle(
      Offset(-itemRadius * 0.2, -itemRadius * 0.4),
      itemRadius * 0.2,
      sparkPaint,
    );
  }

  /// Check if ball collides with this collectible
  bool checkCollision(Vector2 ballPosition, double ballRadius) {
    if (isCollected) return false;

    final center = position + Vector2(itemRadius, itemRadius);
    final distance = (ballPosition - center).length;
    return distance < (itemRadius + ballRadius);
  }

  /// Collect this item
  void collect() {
    isCollected = true;
  }
}
