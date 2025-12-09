import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/game_constants.dart';

/// Ball component with enhanced visuals and animations
class BallComponent extends PositionComponent {
  final double ballRadius;
  final Color ballColor;
  final Color faceColor;

  // Ball physics and movement
  double horizontalVelocity = 0;
  double verticalVelocity = 0;
  double rotationAngle = 0;

  // Squash and stretch animation
  double _squashFactor = 1.0;
  double _stretchFactor = 1.0;
  double _squashTimer = 0;

  // Face feature sizes (relative to ball radius)
  late double eyeRadius;
  late double eyeOffsetX;
  late double eyeOffsetY;
  late double mouthWidth;
  late double mouthHeight;
  late double mouthOffsetY;

  // Paint objects for different parts
  late Paint ballPaint;
  late Paint shadowPaint;
  late Paint eyePaint;
  late Paint mouthPaint;
  late Paint highlightPaint;
  late Paint glowPaint;

  BallComponent({
    this.ballRadius = PhysicsConstants.ballRadius,
    this.ballColor = NeonTheme.ballPrimary,
    this.faceColor = const Color(0xFF000000),
  }) {
    // Set component size based on ball radius
    size = Vector2.all(ballRadius * 2);

    // Calculate face feature sizes relative to ball radius
    _calculateFaceFeatures();

    // Initialize paint objects
    _initializePaints();
  }

  void _calculateFaceFeatures() {
    // Scale face features based on ball radius
    eyeRadius = ballRadius * 0.15;
    eyeOffsetX = ballRadius * 0.35;
    eyeOffsetY = ballRadius * 0.3;
    mouthWidth = ballRadius * 0.8;
    mouthHeight = ballRadius * 0.4;
    mouthOffsetY = ballRadius * 0.2;
  }

  void _initializePaints() {
    // Main ball color with gradient effect
    ballPaint =
        Paint()
          ..color = ballColor
          ..style = PaintingStyle.fill;

    // Shadow for 3D effect
    shadowPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Eyes
    eyePaint =
        Paint()
          ..color = faceColor
          ..style = PaintingStyle.fill;

    // Mouth
    mouthPaint =
        Paint()
          ..color = faceColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = ballRadius * 0.1
          ..strokeCap = StrokeCap.round;

    // Highlight for 3D effect
    highlightPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill;

    // Glow effect
    glowPaint =
        Paint()
          ..color = NeonTheme.ballGlow.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update squash/stretch animation
    if (_squashTimer > 0) {
      _squashTimer -= dt;
      final progress = _squashTimer / VisualConstants.squashStretchDuration;
      _squashFactor = 1.0 - (0.3 * progress);
      _stretchFactor = 1.0 + (0.3 * progress);
    } else {
      _squashFactor = 1.0;
      _stretchFactor = 1.0;
    }
  }

  @override
  void render(Canvas canvas) {
    // Save canvas state for rotation
    canvas.save();

    // Move to center of the ball for rotation
    canvas.translate(ballRadius, ballRadius);

    // Apply squash and stretch
    canvas.scale(_stretchFactor, _squashFactor);

    canvas.rotate(rotationAngle);
    canvas.translate(-ballRadius, -ballRadius);

    // Draw glow effect (larger, blurred circle)
    canvas.drawCircle(
      Offset(ballRadius, ballRadius),
      ballRadius * 1.3,
      glowPaint,
    );

    // Draw shadow (slightly offset)
    canvas.drawCircle(
      Offset(ballRadius + 3, ballRadius + 3),
      ballRadius,
      shadowPaint,
    );

    // Draw main ball
    canvas.drawCircle(Offset(ballRadius, ballRadius), ballRadius, ballPaint);

    // Draw highlight for 3D effect
    canvas.drawCircle(
      Offset(ballRadius - ballRadius * 0.3, ballRadius - ballRadius * 0.3),
      ballRadius * 0.3,
      highlightPaint,
    );

    // Draw happy face features
    _drawHappyFace(canvas);

    // Restore canvas state
    canvas.restore();
  }

  void _drawHappyFace(Canvas canvas) {
    final centerX = ballRadius;
    final centerY = ballRadius;

    // Draw eyes
    // Left eye
    canvas.drawCircle(
      Offset(centerX - eyeOffsetX, centerY - eyeOffsetY),
      eyeRadius,
      eyePaint,
    );

    // Right eye
    canvas.drawCircle(
      Offset(centerX + eyeOffsetX, centerY - eyeOffsetY),
      eyeRadius,
      eyePaint,
    );

    // Draw happy smile
    final mouthPath = Path();
    final mouthLeft = centerX - mouthWidth / 2;
    final mouthRight = centerX + mouthWidth / 2;
    final mouthTop = centerY + mouthOffsetY;
    final mouthBottom = centerY + mouthOffsetY + mouthHeight;

    // Create smile arc
    mouthPath.moveTo(mouthLeft, mouthTop);
    mouthPath.quadraticBezierTo(centerX, mouthBottom, mouthRight, mouthTop);

    canvas.drawPath(mouthPath, mouthPaint);
  }

  /// Update ball rotation based on movement
  void updateRotation(double horizontalVel, double dt) {
    horizontalVelocity = horizontalVel;

    // Calculate rotation based on horizontal movement
    // The ball rotates as it rolls
    if (horizontalVelocity.abs() > 0.1) {
      // Rotation speed proportional to velocity
      final rotationSpeed = horizontalVelocity / ballRadius;
      rotationAngle += rotationSpeed * dt;

      // Keep angle in reasonable range
      if (rotationAngle > 2 * pi) {
        rotationAngle -= 2 * pi;
      } else if (rotationAngle < -2 * pi) {
        rotationAngle += 2 * pi;
      }
    }
  }

  /// Trigger squash/stretch animation on impact
  void triggerSquash() {
    _squashTimer = VisualConstants.squashStretchDuration;
  }

  /// Get the ball's current radius (for collision detection)
  double get radius => ballRadius;

  /// Get ball center position
  Vector2 get center => position + Vector2(ballRadius, ballRadius);

  /// Set ball center position
  set center(Vector2 newCenter) {
    position = newCenter - Vector2(ballRadius, ballRadius);
  }

  /// Update ball position
  void updatePosition(Vector2 newPosition) {
    position = newPosition;
  }

  /// Change ball expression for different emotions
  void setExpression(BallExpression expression) {
    switch (expression) {
      case BallExpression.happy:
        _setHappyExpression();
        break;
      case BallExpression.surprised:
        _setSurprisedExpression();
        break;
      case BallExpression.dizzy:
        _setDizzyExpression();
        break;
      case BallExpression.excited:
        _setExcitedExpression();
        break;
    }
  }

  void _setHappyExpression() {
    eyeRadius = ballRadius * 0.15;
    mouthHeight = ballRadius * 0.4;
    mouthOffsetY = ballRadius * 0.2;
  }

  void _setSurprisedExpression() {
    eyeRadius = ballRadius * 0.2; // Bigger eyes
    mouthHeight = ballRadius * 0.3; // Smaller mouth
    mouthOffsetY = ballRadius * 0.3;
  }

  void _setDizzyExpression() {
    eyeRadius = ballRadius * 0.1; // Smaller eyes
    mouthHeight = ballRadius * 0.2; // Wavy mouth
    mouthOffsetY = ballRadius * 0.4;
  }

  void _setExcitedExpression() {
    eyeRadius = ballRadius * 0.18; // Slightly bigger eyes
    mouthHeight = ballRadius * 0.5; // Bigger smile
    mouthOffsetY = ballRadius * 0.1;
  }

  /// Add bouncing animation effect
  void addBounceEffect() {
    setExpression(BallExpression.excited);
    triggerSquash();
  }

  /// Add spinning effect when jumping
  void addSpinEffect() {
    rotationAngle += pi / 4; // Add extra spin
  }
}

/// Enum for different ball expressions
enum BallExpression { happy, surprised, dizzy, excited }
