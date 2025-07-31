import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_svg/svg.dart';
import 'package:flame_svg/svg_component.dart';
import 'package:flutter/painting.dart';

import 'CurveTrackComponent.dart';
import 'ScrollingBackgroundComponent.dart';

class BallGame extends FlameGame {
  late CircleComponent ball;
  late CurveTrackComponent track;
  late ScrollingBackgroundComponent scrollingBackground;
  final double maxSpeed = 350;
  double velocity = 0;
  double acceleration = 600;
  double friction = 300;
  int direction = 0;

  // Jump and gravity properties
  double verticalVelocity = 0;
  final double gravity = 800; // Gravity force pulling ball down
  final double jumpPower = 450; // Increased jump strength
  final double doubleJumpPower = 700; // Double jump strength
  bool isOnGround = true; // Track if ball is touching the track

  late final World world;
  late final CameraComponent cameraComponent;

  double curveHeight = 40; // amplitude of wave
  double curveFrequency = 2; // wave frequency
  double baseY = 400; // base y for track
  final double trackWidth = 1000;
  final double trackHeight = 20; // Reduced height of the elevated track
  final double ballHoverHeight =
      13; // Increased height above track surface (was 5)

  BallGame();

  @override
  Future<void> onLoad() async {
    final bgSvg = await Svg.load('images/background.svg');

    add(
      SvgComponent(
        svg: bgSvg,
        size: size, // full canvas size
        position: Vector2.zero(), // top-left
        priority: -1,
      ),
    );

    world = World();
    cameraComponent = CameraComponent(world: world);
    addAll([cameraComponent, world]);

    // Add scrolling background first (so it renders behind everything)
    scrollingBackground = ScrollingBackgroundComponent(
      gameWidth: size.x,
      gameHeight: size.y,
    );
    world.add(scrollingBackground);

    // Add curve track to world
    track = CurveTrackComponent(width: trackWidth, baseY: baseY);
    world.add(track);

    // Add ball to world - positioned slightly above the elevated track
    ball = CircleComponent(
      radius: 15, // Slightly smaller for better proportion
      paint: Paint()..color = const Color(0xFFF80404),
    );

    // Position ball above the elevated track
    ball.position = Vector2(
      100,
      track.getTrackTopY(100) - ball.radius - ballHoverHeight,
    );

    world.add(ball);

    // Set up camera to follow the ball smoothly
    cameraComponent.follow(ball);
  }

  void moveLeft() => direction = -1;

  void moveRight() => direction = 1;

  void stop() => direction = 0;

  void jump() {
    if (isOnGround) {
      verticalVelocity = -jumpPower; // Negative because Y increases downward
      isOnGround = false;
    }
  }

  void doubleJump() {
    if (isOnGround) {
      verticalVelocity = -doubleJumpPower; // Much higher jump
      isOnGround = false;
    }
  }

  double calculateTrackTopY() {
    // Return the Y position where the ball should hover above the track
    return track.getTrackTopY(ball.x) - ballHoverHeight;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Horizontal velocity control
    if (direction != 0) {
      velocity += direction * acceleration * dt;
      velocity = velocity.clamp(-maxSpeed, maxSpeed);
    } else {
      if (velocity > 0) {
        velocity -= friction * dt;
        if (velocity < 0) velocity = 0;
      } else if (velocity < 0) {
        velocity += friction * dt;
        if (velocity > 0) velocity = 0;
      }
    }

    // Move ball horizontally
    ball.x += velocity * dt;

    // Keep ball within track bounds
    if (ball.x < ball.radius) {
      ball.x = ball.radius;
      velocity = 0;
    } else if (ball.x > trackWidth - ball.radius) {
      ball.x = trackWidth - ball.radius;
      velocity = 0;
    }

    // Apply gravity and vertical movement
    verticalVelocity += gravity * dt;
    ball.y += verticalVelocity * dt;

    // Check collision with track surface (accounting for hover height)
    final trackTopY = calculateTrackTopY() - ball.radius;

    if (ball.y >= trackTopY) {
      // Ball has landed on or passed through the track
      ball.y = trackTopY;
      verticalVelocity = 0;
      isOnGround = true;
    } else {
      // Ball is in the air
      isOnGround = false;
    }

    // Update background position based on camera/ball position
    scrollingBackground.updateBackgroundPosition(ball.x);
  }
}
