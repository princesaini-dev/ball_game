import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/game_constants.dart';

/// Base class for all obstacles
abstract class ObstacleComponent extends PositionComponent {
  bool isActive = true;

  /// Check if ball collides with this obstacle
  bool checkCollision(Vector2 ballPosition, double ballRadius);

  /// Called when ball collides with obstacle
  void onCollision();
}

/// Rotating blade obstacle
class RotatingBladeComponent extends ObstacleComponent {
  final double bladeRadius;
  final double rotationSpeed;
  double currentRotation = 0;

  late Paint bladePaint;
  late Paint corePaint;
  late Paint glowPaint;

  RotatingBladeComponent({
    required Vector2 position,
    this.bladeRadius = 30.0,
    this.rotationSpeed = 3.0,
  }) {
    this.position = position;
    size = Vector2.all(bladeRadius * 2);

    bladePaint =
        Paint()
          ..color = NeonTheme.obstacleDanger
          ..style = PaintingStyle.fill;

    corePaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    glowPaint =
        Paint()
          ..color = NeonTheme.obstacleDanger.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  }

  @override
  void update(double dt) {
    super.update(dt);
    currentRotation += rotationSpeed * dt;
    if (currentRotation > 2 * pi) {
      currentRotation -= 2 * pi;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(bladeRadius, bladeRadius);
    canvas.rotate(currentRotation);

    // Draw glow
    canvas.drawCircle(Offset.zero, bladeRadius * 1.2, glowPaint);

    // Draw blades
    const bladeCount = 6;
    for (int i = 0; i < bladeCount; i++) {
      final angle = (i / bladeCount) * 2 * pi;
      final path = Path();

      // Create blade shape
      path.moveTo(0, 0);
      path.lineTo(
        cos(angle - 0.2) * bladeRadius * 0.3,
        sin(angle - 0.2) * bladeRadius * 0.3,
      );
      path.lineTo(cos(angle) * bladeRadius, sin(angle) * bladeRadius);
      path.lineTo(
        cos(angle + 0.2) * bladeRadius * 0.3,
        sin(angle + 0.2) * bladeRadius * 0.3,
      );
      path.close();

      canvas.drawPath(path, bladePaint);
    }

    // Draw core
    canvas.drawCircle(Offset.zero, bladeRadius * 0.2, corePaint);

    canvas.restore();
  }

  @override
  bool checkCollision(Vector2 ballPosition, double ballRadius) {
    final center = position + Vector2(bladeRadius, bladeRadius);
    final distance = (ballPosition - center).length;
    return distance < (bladeRadius + ballRadius);
  }

  @override
  void onCollision() {
    // Collision handled by game
  }
}

/// Spike obstacle
class SpikeComponent extends ObstacleComponent {
  final double spikeWidth;
  final double spikeHeight;

  late Paint spikePaint;
  late Paint glowPaint;

  SpikeComponent({
    required Vector2 position,
    this.spikeWidth = 30.0,
    this.spikeHeight = 40.0,
  }) {
    this.position = position;
    size = Vector2(spikeWidth, spikeHeight);

    spikePaint =
        Paint()
          ..color = NeonTheme.obstacleDanger
          ..style = PaintingStyle.fill;

    glowPaint =
        Paint()
          ..color = NeonTheme.obstacleDanger.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  }

  @override
  void render(Canvas canvas) {
    // Draw glow
    final glowPath = Path();
    glowPath.moveTo(spikeWidth / 2, -5);
    glowPath.lineTo(spikeWidth + 5, spikeHeight + 5);
    glowPath.lineTo(-5, spikeHeight + 5);
    glowPath.close();
    canvas.drawPath(glowPath, glowPaint);

    // Draw spike
    final path = Path();
    path.moveTo(spikeWidth / 2, 0);
    path.lineTo(spikeWidth, spikeHeight);
    path.lineTo(0, spikeHeight);
    path.close();

    canvas.drawPath(path, spikePaint);
  }

  @override
  bool checkCollision(Vector2 ballPosition, double ballRadius) {
    // Simple box collision for spikes
    final spikeCenter = position + Vector2(spikeWidth / 2, spikeHeight / 2);
    final dx = (ballPosition.x - spikeCenter.x).abs();
    final dy = (ballPosition.y - spikeCenter.y).abs();

    return dx < (spikeWidth / 2 + ballRadius) &&
        dy < (spikeHeight / 2 + ballRadius);
  }

  @override
  void onCollision() {
    // Collision handled by game
  }
}

/// Moving platform obstacle
class MovingPlatformComponent extends ObstacleComponent {
  final double platformWidth;
  final double platformHeight;
  final Vector2 startPosition;
  final Vector2 endPosition;
  final double moveSpeed;

  double _moveProgress = 0;
  bool _movingForward = true;

  late Paint platformPaint;
  late Paint glowPaint;

  MovingPlatformComponent({
    required this.startPosition,
    required this.endPosition,
    this.platformWidth = 80.0,
    this.platformHeight = 20.0,
    this.moveSpeed = 0.5,
  }) {
    position = startPosition.clone();
    size = Vector2(platformWidth, platformHeight);

    platformPaint =
        Paint()
          ..color = NeonTheme.obstacleWarning
          ..style = PaintingStyle.fill;

    glowPaint =
        Paint()
          ..color = NeonTheme.obstacleWarning.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update movement
    if (_movingForward) {
      _moveProgress += moveSpeed * dt;
      if (_moveProgress >= 1.0) {
        _moveProgress = 1.0;
        _movingForward = false;
      }
    } else {
      _moveProgress -= moveSpeed * dt;
      if (_moveProgress <= 0.0) {
        _moveProgress = 0.0;
        _movingForward = true;
      }
    }

    // Update position
    final t = _moveProgress;
    position = Vector2(
      startPosition.x + (endPosition.x - startPosition.x) * t,
      startPosition.y + (endPosition.y - startPosition.y) * t,
    );
  }

  @override
  void render(Canvas canvas) {
    // Draw glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-5, -5, platformWidth + 10, platformHeight + 10),
        const Radius.circular(8),
      ),
      glowPaint,
    );

    // Draw platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, platformWidth, platformHeight),
        const Radius.circular(5),
      ),
      platformPaint,
    );

    // Draw pattern
    final patternPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    for (double x = 10; x < platformWidth; x += 15) {
      canvas.drawLine(Offset(x, 0), Offset(x, platformHeight), patternPaint);
    }
  }

  @override
  bool checkCollision(Vector2 ballPosition, double ballRadius) {
    final platformCenter =
        position + Vector2(platformWidth / 2, platformHeight / 2);
    final dx = (ballPosition.x - platformCenter.x).abs();
    final dy = (ballPosition.y - platformCenter.y).abs();

    return dx < (platformWidth / 2 + ballRadius) &&
        dy < (platformHeight / 2 + ballRadius);
  }

  @override
  void onCollision() {
    // Collision handled by game
  }
}

/// Pendulum obstacle
class PendulumComponent extends ObstacleComponent {
  final Vector2 anchorPosition;
  final double ropeLength;
  final double swingAngle;
  final double swingSpeed;
  final double bobRadius;

  double _currentAngle = 0;
  double _angleVelocity;

  late Paint ropePaint;
  late Paint bobPaint;
  late Paint glowPaint;

  PendulumComponent({
    required this.anchorPosition,
    this.ropeLength = 100.0,
    this.swingAngle = pi / 3,
    this.swingSpeed = 2.0,
    this.bobRadius = 15.0,
  }) : _angleVelocity = swingSpeed {
    position = anchorPosition.clone();
    size = Vector2(ropeLength * 2, ropeLength + bobRadius * 2);

    ropePaint =
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    bobPaint =
        Paint()
          ..color = NeonTheme.obstacleDanger
          ..style = PaintingStyle.fill;

    glowPaint =
        Paint()
          ..color = NeonTheme.obstacleDanger.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Simple pendulum motion
    _currentAngle += _angleVelocity * dt;

    // Reverse direction at swing limits
    if (_currentAngle.abs() > swingAngle) {
      _angleVelocity = -_angleVelocity;
      _currentAngle = _currentAngle.clamp(-swingAngle, swingAngle);
    }
  }

  @override
  void render(Canvas canvas) {
    // Calculate bob position
    final bobX = sin(_currentAngle) * ropeLength;
    final bobY = cos(_currentAngle) * ropeLength;

    // Draw rope
    canvas.drawLine(const Offset(0, 0), Offset(bobX, bobY), ropePaint);

    // Draw glow
    canvas.drawCircle(Offset(bobX, bobY), bobRadius * 1.5, glowPaint);

    // Draw bob
    canvas.drawCircle(Offset(bobX, bobY), bobRadius, bobPaint);
  }

  @override
  bool checkCollision(Vector2 ballPosition, double ballRadius) {
    final bobX = sin(_currentAngle) * ropeLength;
    final bobY = cos(_currentAngle) * ropeLength;
    final bobPosition = anchorPosition + Vector2(bobX, bobY);

    final distance = (ballPosition - bobPosition).length;
    return distance < (bobRadius + ballRadius);
  }

  @override
  void onCollision() {
    // Collision handled by game
  }
}
