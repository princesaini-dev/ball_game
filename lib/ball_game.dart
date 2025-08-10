import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_svg/svg.dart';
import 'package:flame_svg/svg_component.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:isolate';
import 'dart:async';

import 'CurveTrackComponent.dart';
import 'ScrollingBackgroundComponent.dart';
import 'BallComponent.dart';

class BallGame extends FlameGame with HasKeyboardHandlerComponents {
  late BallComponent ball;
  late CustomTrackComponent track;
  late ScrollingBackgroundComponent scrollingBackground;
  final double maxSpeed = 350;
  double velocity = 0;
  double acceleration = 600;
  double friction = 300;
  int direction = 0;

  // Jump and gravity properties - optimized for smooth movement
  double verticalVelocity = 0;
  final double gravity = 800;
  final double jumpPower = 450;
  final double doubleJumpPower = 700;
  final double bouncePower = 550;
  bool isOnGround = true;

  // Anti-vibration system
  double _previousTrackY = 0;
  final double _vibrationDamping = 0.8; // Reduces sudden height changes
  final double _groundTolerance = 2.0; // Tolerance for ground detection

  // Performance optimization variables
  double _lastUpdateTime = 0;
  final double _frameTime = 1.0 / 60.0;

  // Fixed world coordinates - track doesn't move with camera
  late final World world;
  late final CameraComponent cameraComponent;

  // Screen dimensions for proper sizing
  double get screenWidth => size.x;

  double get screenHeight => size.y;

  double curveHeight = 40;
  double curveFrequency = 2;
  double baseY = 400;
  final double trackWidth = 5000; // Long track for testing
  final double trackHeight = 40;
  final double ballHoverHeight = 13;

  // Physics calculation isolate for heavy computations
  Isolate? _physicsIsolate;
  ReceivePort? _receivePort;

  BallGame();

  bool movingLeft = false;
  bool movingRight = false;

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final result = super.onKeyEvent(event, keysPressed);

    movingLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    movingRight = keysPressed.contains(LogicalKeyboardKey.arrowRight);
    // Bounce only on single press
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      bounce();
    }

    return KeyEventResult.handled;
  }

  @override
  Future<void> onLoad() async {
    // Initialize world and camera first
    world = World();
    cameraComponent = CameraComponent(world: world);
    addAll([cameraComponent, world]);

    // Load background efficiently with fallback
    try {
      final bgSvg = await Svg.load('images/background.svg');
      add(
        SvgComponent(
          svg: bgSvg,
          size: size,
          position: Vector2.zero(),
          priority: -2, // Behind everything
        ),
      );
    } catch (e) {
      print('Background SVG failed to load: $e');
    }

    // Initialize optimized components in world coordinates
    await _initializeOptimizedComponents();

    // FIXED: Set camera to start at left edge of world (x=0)
    // Camera position is the CENTER of what it shows, so to show x=0 to x=screenWidth,
    // camera should be at x=screenWidth/2
    final initialCameraX =
        screenWidth * 0.5; // Shows world from x=0 to x=screenWidth
    final initialCameraY =
        baseY - (screenHeight * 0.4); // Adjusted to show track better
    cameraComponent.viewfinder.position = Vector2(
      initialCameraX,
      initialCameraY,
    );

    // Remove camera bounds so it can follow the ball horizontally
    cameraComponent.setBounds(null);
  }

  Future<void> _initializeOptimizedComponents() async {
    // FIXED: Position track to fill frame better - move track higher up
    baseY = screenHeight * 0.6; // Move track higher to reduce top margin

    // Add FIXED scrolling background (doesn't move with track)
    scrollingBackground = ScrollingBackgroundComponent(
      gameWidth: screenWidth,
      gameHeight: screenHeight,
    );
    world.add(scrollingBackground);

    // Add FIXED curve track (stays in world coordinates)
    track = CustomTrackComponent(width: trackWidth, baseY: baseY - 100);

    // ACTIVATE: Load a platformer pattern with gaps and height differences
    track.loadTrackPattern('platformer'); // Try this for platform jumping!
    // track.loadTrackPattern('stairs_up');        // Or this for stair climbing
    // track.loadTrackPattern('scattered_platforms'); // Or this for scattered platforms
    // track.toggleControlPointsVisibility();      // Uncomment to see control points

    world.add(track);

    // Create optimized ball component
    ball = BallComponent();

    // FIXED: Position ball at left edge of track (x=50 instead of x=100)
    final initialX = screenWidth / 2; // Start closer to left edge
    final initialTrackY = track.getTrackTopY(initialX);
    ball.position = Vector2(
      initialX,
      initialTrackY ?? 0 - ball.radius - ballHoverHeight,
    );

    // Initialize previous track position for anti-vibration
    _previousTrackY = initialTrackY ?? 0;

    world.add(ball);
  }

  // Movement methods with immediate response
  void moveLeft() {
    direction = -1;
  }

  void moveRight() {
    direction = 1;
  }

  void stop() {
    direction = 0;
  }

  // FIXED: Immediate jump response
  void jump() {
    if (isOnGround) {
      verticalVelocity = -jumpPower;
      isOnGround = false;

      // Add excited expression when jumping
      ball.setExpression(BallExpression.excited);
      ball.addSpinEffect();
    }
  }

  void doubleJump() {
    if (isOnGround) {
      verticalVelocity = -doubleJumpPower;
      isOnGround = false;

      // Add surprised expression for double jump
      ball.setExpression(BallExpression.surprised);
      ball.addSpinEffect();
    }
  }

  // FIXED: Immediate bounce response - no delay
  void bounce() {
    verticalVelocity = -bouncePower;
    isOnGround = false;

    // Add visual effects to the happy face ball
    ball.addBounceEffect();
    ball.addSpinEffect();

    if (direction == 0) {
      velocity += (velocity > 0 ? 50 : -50);
    }
  }

  // FIXED: Anti-vibration track height calculation with gap support
  double? calculateTrackTopY() {
    final trackY = track.getTrackTopY(ball.x);

    // If there's no track at this position (gap), return null
    if (trackY == null) return null;

    // Apply damping to prevent sudden height changes (anti-vibration)
    final dampedTrackY =
        _previousTrackY + (trackY - _previousTrackY) * _vibrationDamping;

    _previousTrackY = dampedTrackY;

    return dampedTrackY - ballHoverHeight;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Continuous movement if key is held
    if (movingLeft) {
      moveLeft();
    } else if (movingRight) {
      moveRight();
    } else {
      Future.delayed(Duration(seconds: 3), () => stop());
    }

    // PERFORMANCE: Frame rate control
    _lastUpdateTime += dt;

    if (_lastUpdateTime < _frameTime) {
      return;
    }

    final actualDt = _lastUpdateTime;
    _lastUpdateTime = 0;

    _updatePhysics(actualDt);
    _updateHorizontalCamera();
  }

  void _updateHorizontalCamera() {
    // FIXED: Proper horizontal camera tracking with correct vertical framing
    final targetCameraX = ball.x;

    // FIXED: Adjust camera Y to better frame the track and eliminate top margin
    final properCameraY =
        baseY - (screenHeight * 0.4); // Show track in middle-lower area

    // Update camera position to follow ball horizontally only
    cameraComponent.viewfinder.position = Vector2(targetCameraX, properCameraY);
  }

  void _updatePhysics(double dt) {
    // Smooth horizontal movement with edge detection
    if (direction != 0) {
      velocity += direction * acceleration * dt;
      velocity = velocity.clamp(-maxSpeed, maxSpeed);

      // Check for platform edges before moving
      final newX = ball.x + velocity * dt;
      if (_shouldStopAtEdge(newX, velocity > 0)) {
        velocity = 0; // Stop the ball at the edge
        ball.setExpression(
          BallExpression.surprised,
        ); // Show that ball can't proceed
      } else if (newX >= ball.radius && newX <= trackWidth - ball.radius) {
        ball.x = newX;
      } else {
        ball.x = newX.clamp(ball.radius, trackWidth - ball.radius);
        velocity = 0;
      }
    } else {
      final frictionForce = friction * dt;
      if (velocity > frictionForce) {
        velocity -= frictionForce;
      } else if (velocity < -frictionForce) {
        velocity += frictionForce;
      } else {
        velocity = 0;
      }
    }

    // Update ball rotation based on horizontal movement
    ball.updateRotation(velocity, dt);

    // Smooth vertical physics with anti-vibration
    verticalVelocity += gravity * dt;
    ball.y += verticalVelocity * dt;

    // Handle gaps and platform collision detection
    final trackTopY = calculateTrackTopY();

    if (trackTopY == null) {
      // Ball is over a gap - let it fall with gravity
      isOnGround = false;
      ball.setExpression(
        BallExpression.surprised,
      ); // Show surprise when falling
    } else {
      // There's a platform at this position
      final platformY = trackTopY - ball.radius;

      if (ball.y >= platformY - _groundTolerance) {
        // Ball has landed on platform
        ball.y = platformY;

        // Only stop vertical velocity if moving downward
        if (verticalVelocity > 0) {
          verticalVelocity = 0;
          ball.setExpression(BallExpression.happy); // Happy when landed safely
        }

        isOnGround = true;
      } else {
        isOnGround = false;
      }
    }

    // Prevent ball from falling below screen (respawn or game over)
    if (ball.y > baseY + 300) {
      _respawnBall();
    }
  }

  // Check if ball should stop at platform edge due to height difference
  bool _shouldStopAtEdge(double newX, bool movingRight) {
    if (!isOnGround) return false; // Only check edges when on ground

    // Get current platform height
    final currentTrackY = track.getTrackTopY(ball.x);
    if (currentTrackY == null) return false;

    // Check next position
    final lookAheadDistance = ball.radius + 5; // Small look-ahead distance
    final checkX =
        movingRight ? newX + lookAheadDistance : newX - lookAheadDistance;
    final nextTrackY = track.getTrackTopY(checkX);

    // If there's no track ahead (gap), let normal gap handling take care of it
    if (nextTrackY == null) return false;

    // Check if next platform is significantly higher
    final heightDifference = currentTrackY - nextTrackY;
    final maxStepHeight =
        30; // Maximum height the ball can "step up" automatically

    // Stop if next platform is too high to step up to
    if (heightDifference > maxStepHeight) {
      return true;
    }

    // Also check for platform edge (end of current segment)
    final currentSegment = track.findSegmentAtX(ball.x);
    if (currentSegment != null) {
      final edgeBuffer = ball.radius + 2;

      if (movingRight && newX + edgeBuffer >= currentSegment.endX) {
        // At right edge of current segment
        final nextSegment = track.findSegmentAtX(currentSegment.endX + 10);
        if (nextSegment != null && !nextSegment.isConnectedToPrevious) {
          // Next segment exists but is disconnected (gap or height difference)
          final currentHeight = currentSegment.controlPoints.last.y;
          final nextHeight = nextSegment.controlPoints.first.y;

          // Stop if there's a significant height difference up
          if (currentHeight - nextHeight > maxStepHeight) {
            return true;
          }
        }
      } else if (!movingRight && newX - edgeBuffer <= currentSegment.startX) {
        // At left edge of current segment
        // Find previous segment
        TrackSegment? prevSegment;
        for (final segment in track.trackSegments) {
          if (segment.endX <= currentSegment.startX - 5) {
            prevSegment = segment;
          }
        }

        if (prevSegment != null) {
          final currentHeight = currentSegment.controlPoints.first.y;
          final prevHeight = prevSegment.controlPoints.last.y;

          // Stop if there's a significant height difference up
          if (currentHeight - prevHeight > maxStepHeight) {
            return true;
          }
        }
      }
    }

    return false;
  }

  // Respawn ball at the beginning or last safe platform
  void _respawnBall() {
    ball.x = 50; // Reset to start position
    final respawnTrackY = track.getTrackTopY(ball.x);
    if (respawnTrackY != null) {
      ball.y = respawnTrackY - ball.radius - ballHoverHeight;
      verticalVelocity = 0;
      velocity = 0;
      isOnGround = true;
      ball.setExpression(BallExpression.happy);
    }
  }

  @override
  onRemove() {
    _physicsIsolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    super.onRemove();
  }
}
