import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/game_constants.dart';

/// Laser beam obstacle that shoots vertical beams
class LaserBeamComponent extends PositionComponent {
  final double beamWidth = 8.0;
  final double beamHeight = 400.0;
  double animationTimer = 0;
  double warningTimer = 0;
  bool isActive = false;
  final double cycleDuration = 3.0; // 3 seconds per cycle
  final double warningDuration = 1.0; // 1 second warning
  final double activeDuration = 1.5; // 1.5 seconds active

  late Paint beamPaint;
  late Paint warningPaint;
  late Paint glowPaint;
  late Paint emitterPaint;

  LaserBeamComponent({required Vector2 position}) {
    this.position = position;
    size = Vector2(30, 60);
    _initializePaints();
  }

  void _initializePaints() {
    beamPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              NeonTheme.obstacleDanger.withValues(alpha: 0.9),
              NeonTheme.obstacleDanger.withValues(alpha: 0.7),
              NeonTheme.obstacleDanger.withValues(alpha: 0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, beamWidth, beamHeight))
          ..style = PaintingStyle.fill;

    warningPaint =
        Paint()
          ..color = Colors.yellow.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill;

    glowPaint =
        Paint()
          ..color = NeonTheme.obstacleDanger.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    emitterPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [NeonTheme.obstacleDanger, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, 30, 60))
          ..style = PaintingStyle.fill;
  }

  @override
  void update(double dt) {
    super.update(dt);

    animationTimer += dt;

    if (animationTimer < warningDuration) {
      // Warning phase
      isActive = false;
      warningTimer += dt;
    } else if (animationTimer < warningDuration + activeDuration) {
      // Active phase
      isActive = true;
    } else if (animationTimer >= cycleDuration) {
      // Reset cycle
      animationTimer = 0;
      warningTimer = 0;
      isActive = false;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    // Draw emitter box
    final emitterRect = Rect.fromLTWH(0, 0, 30, 60);
    canvas.drawRect(emitterRect, emitterPaint);

    // Draw border
    final borderPaint =
        Paint()
          ..color = NeonTheme.obstacleDanger
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawRect(emitterRect, borderPaint);

    // Draw warning or active beam
    if (isActive) {
      // Draw glow
      canvas.drawRect(
        Rect.fromLTWH(15 - beamWidth, 60, beamWidth * 2, beamHeight),
        glowPaint,
      );

      // Draw beam
      canvas.drawRect(
        Rect.fromLTWH(15 - beamWidth / 2, 60, beamWidth, beamHeight),
        beamPaint,
      );

      // Draw sparks along beam
      final random = Random();
      for (int i = 0; i < 5; i++) {
        final sparkY = 60 + random.nextDouble() * beamHeight;
        final sparkPaint =
            Paint()
              ..color = Colors.white.withValues(alpha: 0.8)
              ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(15, sparkY),
          2 + random.nextDouble() * 2,
          sparkPaint,
        );
      }
    } else if (animationTimer < warningDuration) {
      // Warning flash
      final flashAlpha = (sin(warningTimer * 10) * 0.5 + 0.5);
      final flashPaint =
          Paint()
            ..color = Colors.yellow.withValues(alpha: flashAlpha * 0.6)
            ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(15 - beamWidth / 2, 60, beamWidth, beamHeight),
        flashPaint,
      );
    }

    canvas.restore();
  }

  bool checkCollision(Vector2 ballPosition, double ballRadius) {
    if (!isActive) return false;

    // Check if ball intersects with the laser beam
    final beamLeft = position.x + 15 - beamWidth / 2;
    final beamRight = position.x + 15 + beamWidth / 2;
    final beamTop = position.y + 60;
    final beamBottom = position.y + 60 + beamHeight;

    return ballPosition.x + ballRadius > beamLeft &&
        ballPosition.x - ballRadius < beamRight &&
        ballPosition.y + ballRadius > beamTop &&
        ballPosition.y - ballRadius < beamBottom;
  }

  void onCollision() {
    // Collision handled by game
  }
}

/// Pulsating spike obstacle
class PulsatingSpikeComponent extends PositionComponent {
  double pulseTimer = 0;
  final double pulseSpeed = 3.0;

  late Paint spikePaint;
  late Paint glowPaint;

  PulsatingSpikeComponent({required Vector2 position}) {
    this.position = position;
    size = Vector2(30, 40);
    _initializePaints();
  }

  void _initializePaints() {
    spikePaint =
        Paint()
          ..color = NeonTheme.obstacleDanger
          ..style = PaintingStyle.fill;

    glowPaint =
        Paint()
          ..color = NeonTheme.obstacleDanger.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
  }

  @override
  void update(double dt) {
    super.update(dt);
    pulseTimer += dt * pulseSpeed;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    final pulseFactor = (sin(pulseTimer) * 0.3 + 1.0);
    final glowSize = 20 * pulseFactor;

    // Draw glow
    canvas.drawCircle(Offset(15, 20), glowSize, glowPaint);

    // Draw spike triangle
    final path = Path();
    path.moveTo(15, 0); // Top point
    path.lineTo(0, 40); // Bottom left
    path.lineTo(30, 40); // Bottom right
    path.close();

    canvas.drawPath(path, spikePaint);

    // Draw highlight
    final highlightPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3 * pulseFactor)
          ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(15, 5);
    highlightPath.lineTo(10, 20);
    highlightPath.lineTo(15, 15);
    highlightPath.close();

    canvas.drawPath(highlightPath, highlightPaint);

    canvas.restore();
  }

  bool checkCollision(Vector2 ballPosition, double ballRadius) {
    // Triangle collision - approximate with circle
    final center = position + Vector2(15, 20);
    final distance = (ballPosition - center).length;
    return distance < (ballRadius + 15);
  }

  void onCollision() {
    // Collision handled by game
  }
}

/// Saw blade that moves up and down
class VerticalSawComponent extends PositionComponent {
  final double moveRange = 150.0;
  final double moveSpeed = 100.0;
  double moveOffset = 0;
  double rotationAngle = 0;
  final Vector2 startPosition;

  late Paint bladePaint;
  late Paint glowPaint;

  VerticalSawComponent({required Vector2 position})
    : startPosition = position.clone() {
    this.position = position;
    size = Vector2(50, 50);
    _initializePaints();
  }

  void _initializePaints() {
    bladePaint =
        Paint()
          ..color = NeonTheme.obstacleDanger
          ..style = PaintingStyle.fill;

    glowPaint =
        Paint()
          ..color = NeonTheme.obstacleDanger.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move up and down
    moveOffset += moveSpeed * dt;
    final yOffset = sin(moveOffset) * moveRange;
    position.y = startPosition.y + yOffset;

    // Rotate
    rotationAngle += dt * 5;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(25, 25);
    canvas.rotate(rotationAngle);

    // Draw glow
    canvas.drawCircle(Offset.zero, 35, glowPaint);

    // Draw saw blade
    final path = Path();
    const teeth = 12;
    const outerRadius = 25.0;
    const innerRadius = 20.0;

    for (int i = 0; i < teeth * 2; i++) {
      final angle = (i * pi) / teeth;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, bladePaint);

    // Draw center
    final centerPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 8, centerPaint);

    canvas.restore();
  }

  bool checkCollision(Vector2 ballPosition, double ballRadius) {
    final center = position + Vector2(25, 25);
    final distance = (ballPosition - center).length;
    return distance < (ballRadius + 25);
  }

  void onCollision() {
    // Collision handled by game
  }
}
