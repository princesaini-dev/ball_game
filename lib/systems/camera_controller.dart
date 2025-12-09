import 'dart:math';
import 'package:flame/components.dart';
import '../config/game_constants.dart';

/// Camera controller with smooth following and screen shake
class CameraController {
  final CameraComponent camera;
  final double screenWidth;
  final double screenHeight;
  final double baseY;

  // Screen shake properties
  bool _isShaking = false;
  double _shakeTimer = 0;
  double _shakeIntensity = 0;
  final Random _random = Random();

  // Smooth following
  Vector2 _targetPosition = Vector2.zero();

  CameraController({
    required this.camera,
    required this.screenWidth,
    required this.screenHeight,
    required this.baseY,
  });

  /// Update camera to follow target position
  void update(double dt, Vector2 ballPosition, double ballVelocity) {
    // Calculate target camera position with look-ahead
    final lookAhead =
        ballVelocity > 0
            ? VisualConstants.cameraLookAhead
            : -VisualConstants.cameraLookAhead;

    _targetPosition = Vector2(
      ballPosition.x + lookAhead,
      baseY - (screenHeight * 0.4),
    );

    // Smooth camera movement with easing
    final currentPos = camera.viewfinder.position;
    final newPos = Vector2(
      currentPos.x +
          (_targetPosition.x - currentPos.x) * VisualConstants.cameraEasing,
      currentPos.y +
          (_targetPosition.y - currentPos.y) * VisualConstants.cameraEasing,
    );

    // Apply screen shake if active
    if (_isShaking) {
      _shakeTimer -= dt;

      if (_shakeTimer <= 0) {
        _isShaking = false;
        _shakeIntensity = 0;
      } else {
        // Add random offset for shake effect
        final shakeX = (_random.nextDouble() - 0.5) * _shakeIntensity;
        final shakeY = (_random.nextDouble() - 0.5) * _shakeIntensity;

        newPos.x += shakeX;
        newPos.y += shakeY;

        // Reduce intensity over time
        _shakeIntensity *= 0.9;
      }
    }

    camera.viewfinder.position = newPos;
  }

  /// Trigger screen shake effect
  void shake({double intensity = VisualConstants.screenShakeIntensity}) {
    _isShaking = true;
    _shakeTimer = VisualConstants.screenShakeDuration;
    _shakeIntensity = intensity;
  }

  /// Initialize camera position
  void initialize(Vector2 initialPosition) {
    _targetPosition = initialPosition;
    camera.viewfinder.position = initialPosition;
  }
}
