import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'components/ball_component.dart';
import 'components/track_component.dart';
import 'components/background_component.dart';
import 'components/particle_system.dart';
import 'components/obstacle_component.dart';
import 'components/advanced_obstacles.dart';
import 'components/collectible_component.dart';
import 'systems/camera_controller.dart';
import 'config/game_constants.dart';
import 'config/game_state.dart';

/// Enhanced ball game with neon theme and advanced features
class BallGame extends FlameGame with HasKeyboardHandlerComponents {
  late BallComponent ball;
  late TrackComponent track;
  late BackgroundComponent background;
  late ParticleSystem particleSystem;
  late CameraController cameraController;

  // Game state
  GameState gameState = GameState.start;
  int score = 0;
  double distance = 0;
  int combo = 0;
  double comboTimer = 0;

  // Callback for game state changes
  void Function(GameState)? onGameStateChanged;

  // Debug mode
  bool debugMode = true; // Only visible in debug builds
  bool collisionEnabled = true; // Toggle for obstacle collision

  // Physics
  double velocity = 0;
  double verticalVelocity = 0;
  int direction = 0;
  bool isOnGround = true;

  // Bounce limiting
  int airBounceCount = 0; // Track bounces while in air
  static const int maxAirBounces = 2; // Maximum bounces before touching ground

  // Anti-vibration system
  double _previousTrackY = 0;

  // Input state
  bool movingLeft = false;
  bool movingRight = false;

  // Particle trail
  int _particleFrameCounter = 0;

  // World and camera
  late final World world;
  late final CameraComponent cameraComponent;

  // Screen dimensions
  double get screenWidth => size.x;
  double get screenHeight => size.y;

  final double baseY = 400;

  // Obstacles and collectibles (using PositionComponent to support all types)
  final List<PositionComponent> obstacles = [];
  final List<CollectibleComponent> collectibles = [];

  BallGame() : super() {
    // Disable Flame's built-in debug mode (removes x/y coordinates)
    debugMode = false;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);

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

    // Initialize components
    await _initializeComponents();

    // Initialize camera controller
    cameraController = CameraController(
      camera: cameraComponent,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      baseY: baseY,
    );

    final initialCameraX = screenWidth * 0.5;
    final initialCameraY = baseY - (screenHeight * 0.4);
    cameraController.initialize(Vector2(initialCameraX, initialCameraY));

    cameraComponent.setBounds(null);
  }

  Future<void> _initializeComponents() async {
    // Add background
    background = BackgroundComponent(
      gameWidth: screenWidth,
      gameHeight: screenHeight,
    );
    world.add(background);

    // Add particle system
    particleSystem = ParticleSystem();
    world.add(particleSystem);

    // Add track with neon city pattern
    track = TrackComponent(width: GameConfig.trackWidth, baseY: baseY);
    track.loadTrackPattern('neon_city');
    world.add(track);

    // Create ball
    ball = BallComponent();
    final initialX = screenWidth / 2;
    final initialTrackY = track.getTrackTopY(initialX);
    ball.position = Vector2(
      initialX,
      (initialTrackY ?? 0) - ball.radius - PhysicsConstants.ballHoverHeight,
    );

    _previousTrackY = initialTrackY ?? 0;
    world.add(ball);

    // Spawn obstacles and collectibles
    _spawnGameElements();
  }

  void _spawnGameElements() {
    final random = Random();

    // Safe zone: No obstacles before x=1000
    const safeZoneEnd = 1000.0;

    // ========== LEVEL 1: EASY (1000-7000) ==========
    // Basic obstacles - rotating blades and simple spikes
    for (int i = 0; i < 8; i++) {
      final x = 1200 + (i * 700.0) + random.nextDouble() * 100;
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final blade = RotatingBladeComponent(
          position: Vector2(x, trackY - 80),
          rotationSpeed: 1.5 + random.nextDouble(),
        );
        obstacles.add(blade);
        world.add(blade);
      }
    }

    for (int i = 0; i < 12; i++) {
      final x = 1500 + (i * 450.0) + random.nextDouble() * 80;
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final spike = SpikeComponent(position: Vector2(x - 15, trackY - 40));
        obstacles.add(spike);
        world.add(spike);
      }
    }

    // ========== LEVEL 2: MEDIUM (7000-14000) ==========
    // Add pulsating spikes and more blades
    for (int i = 0; i < 10; i++) {
      final x = 7200 + (i * 650.0) + random.nextDouble() * 100;
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final blade = RotatingBladeComponent(
          position: Vector2(x, trackY - 80),
          rotationSpeed: 2.0 + random.nextDouble() * 1.5,
        );
        obstacles.add(blade);
        world.add(blade);
      }
    }

    for (int i = 0; i < 15; i++) {
      final x = 7400 + (i * 430.0) + random.nextDouble() * 80;
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final pulsatingSpike = PulsatingSpikeComponent(
          position: Vector2(x - 15, trackY - 40),
        );
        obstacles.add(pulsatingSpike);
        world.add(pulsatingSpike);
      }
    }

    // Add vertical saws
    for (int i = 0; i < 6; i++) {
      final x = 8000 + (i * 950.0) + random.nextDouble() * 150;
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final saw = VerticalSawComponent(
          position: Vector2(x - 25, trackY - 200),
        );
        obstacles.add(saw);
        world.add(saw);
      }
    }

    // ========== LEVEL 3: HARD (14000-20000) ==========
    // Add laser beams, more saws, and pendulums
    for (int i = 0; i < 12; i++) {
      final x = 14300 + (i * 450.0) + random.nextDouble() * 100;
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final laser = LaserBeamComponent(
          position: Vector2(x - 15, trackY - 60),
        );
        obstacles.add(laser);
        world.add(laser);
      }
    }

    for (int i = 0; i < 8; i++) {
      final x = 14600 + (i * 650.0) + random.nextDouble() * 120;
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final saw = VerticalSawComponent(
          position: Vector2(x - 25, trackY - 200),
        );
        obstacles.add(saw);
        world.add(saw);
      }
    }

    for (int i = 0; i < 20; i++) {
      final x = 14800 + (i * 280.0) + random.nextDouble() * 60;
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final pulsatingSpike = PulsatingSpikeComponent(
          position: Vector2(x - 15, trackY - 40),
        );
        obstacles.add(pulsatingSpike);
        world.add(pulsatingSpike);
      }
    }

    for (int i = 0; i < 5; i++) {
      final x = 15500 + (i * 850.0);
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final pendulum = PendulumComponent(
          anchorPosition: Vector2(x, trackY - 150),
          ropeLength: 120,
          swingSpeed: 2.5,
        );
        obstacles.add(pendulum);
        world.add(pendulum);
      }
    }

    // ========== COLLECTIBLES ACROSS ALL LEVELS ==========
    // Coins throughout
    for (int i = 0; i < 80; i++) {
      final x = 1000 + (i * 230.0) + random.nextDouble() * 50;
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final coin = CollectibleComponent(
          position: Vector2(x, trackY - 60 - random.nextDouble() * 40),
          type: CollectibleType.coin,
        );
        collectibles.add(coin);
        world.add(coin);
      }
    }

    // Stars (rarer, higher value)
    for (int i = 0; i < 25; i++) {
      final x = 1500 + (i * 720.0) + random.nextDouble() * 100;
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final star = CollectibleComponent(
          position: Vector2(x, trackY - 100 - random.nextDouble() * 50),
          type: CollectibleType.star,
        );
        collectibles.add(star);
        world.add(star);
      }
    }

    // Gems (very rare, highest value)
    for (int i = 0; i < 10; i++) {
      final x = 3000 + (i * 1600.0) + random.nextDouble() * 200;
      final trackY = track.getTrackTopY(x);
      if (trackY != null) {
        final gem = CollectibleComponent(
          position: Vector2(x, trackY - 120 - random.nextDouble() * 60),
          type: CollectibleType.gem,
        );
        collectibles.add(gem);
        world.add(gem);
      }
    }
  }

  void bounce() {
    // Only allow bounce if we haven't exceeded air bounce limit
    if (airBounceCount >= maxAirBounces) {
      return; // Can't bounce anymore until touching ground
    }

    verticalVelocity = -PhysicsConstants.bouncePower;
    isOnGround = false;
    airBounceCount++; // Increment air bounce counter

    ball.addBounceEffect();
    ball.addSpinEffect();

    // Emit explosion particles
    particleSystem.emitExplosion(ball.center, NeonTheme.ballGlow, count: 10);

    // Screen shake on bounce
    cameraController.shake(intensity: 5);

    if (direction == 0) {
      velocity += (velocity > 0 ? 50 : -50);
    }
  }

  double? calculateTrackTopY() {
    final trackY = track.getTrackTopY(ball.x);
    if (trackY == null) return null;

    final dampedTrackY =
        _previousTrackY +
        (trackY - _previousTrackY) * PhysicsConstants.vibrationDamping;

    _previousTrackY = dampedTrackY;

    return dampedTrackY - PhysicsConstants.ballHoverHeight;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Only update game logic when playing
    if (gameState != GameState.playing) {
      return;
    }

    // Continuous movement if key is held
    if (movingLeft) {
      direction = -1;
    } else if (movingRight) {
      direction = 1;
    } else {
      direction = 0;
    }

    _updatePhysics(dt);
    _updateCollisions();
    _updateCombo(dt);
    _updateParticles();

    // Update camera
    cameraController.update(dt, ball.center, velocity);

    // Update distance
    distance = ball.x / 10;
  }

  void _updatePhysics(double dt) {
    // Smooth horizontal movement
    if (direction != 0) {
      velocity += direction * PhysicsConstants.acceleration * dt;
      velocity = velocity.clamp(
        -PhysicsConstants.maxSpeed,
        PhysicsConstants.maxSpeed,
      );

      final newX = ball.x + velocity * dt;
      if (newX >= ball.radius && newX <= GameConfig.trackWidth - ball.radius) {
        ball.x = newX;
      } else {
        ball.x = newX.clamp(ball.radius, GameConfig.trackWidth - ball.radius);
        velocity = 0;
      }
    } else {
      final frictionForce = PhysicsConstants.friction * dt;
      if (velocity > frictionForce) {
        velocity -= frictionForce;
      } else if (velocity < -frictionForce) {
        velocity += frictionForce;
      } else {
        velocity = 0;
      }
    }

    // Update ball rotation
    ball.updateRotation(velocity, dt);

    // Vertical physics with gravity
    verticalVelocity += PhysicsConstants.gravity * dt;
    ball.y += verticalVelocity * dt;

    // Handle gaps and platform collision
    final trackTopY = calculateTrackTopY();

    if (trackTopY == null) {
      // Ball is over a gap - let it fall
      isOnGround = false;
      ball.setExpression(BallExpression.surprised);
    } else {
      // There's a platform at this position
      final platformY = trackTopY - ball.radius;

      if (ball.y >= platformY - PhysicsConstants.groundTolerance) {
        // Ball has landed on platform
        ball.y = platformY;

        // Apply bounce physics with energy loss
        if (verticalVelocity > PhysicsConstants.minBounceVelocity) {
          verticalVelocity =
              -verticalVelocity * PhysicsConstants.bounceEnergyLoss;
          ball.triggerSquash();

          // Emit dust particles on landing
          particleSystem.emitDust(
            Vector2(ball.x, ball.y + ball.radius),
            count: 3,
          );
        } else if (verticalVelocity > 0) {
          verticalVelocity = 0;
          ball.setExpression(BallExpression.happy);
        }

        isOnGround = true;
        airBounceCount = 0; // Reset bounce counter when touching ground
      } else {
        isOnGround = false;
      }
    }

    // Respawn if fallen too far
    if (ball.y > baseY + 300) {
      _respawnBall();
    }
  }

  void _updateCollisions() {
    final ballPos = ball.center;

    // Check obstacle collisions (but skip moving platforms - they're safe!)
    // Skip all collision checks if debug mode has collision disabled
    if (collisionEnabled) {
      for (final obstacle in obstacles) {
        // Moving platforms are safe to stand on, only blades and spikes are dangerous
        if (obstacle is MovingPlatformComponent) {
          continue; // Skip collision check for moving platforms
        }

        // Check collision based on obstacle type
        bool hasCollision = false;

        if (obstacle is ObstacleComponent) {
          hasCollision = obstacle.checkCollision(ballPos, ball.radius);
        } else if (obstacle is LaserBeamComponent) {
          hasCollision = obstacle.checkCollision(ballPos, ball.radius);
        } else if (obstacle is PulsatingSpikeComponent) {
          hasCollision = obstacle.checkCollision(ballPos, ball.radius);
        } else if (obstacle is VerticalSawComponent) {
          hasCollision = obstacle.checkCollision(ballPos, ball.radius);
        }

        if (hasCollision) {
          _handleObstacleCollision();
        }
      }
    }

    // Check collectible collisions
    for (final collectible in collectibles) {
      if (collectible.checkCollision(ballPos, ball.radius)) {
        _collectItem(collectible);
      }
    }
  }

  void _handleObstacleCollision() {
    // Trigger game over
    gameState = GameState.gameOver;
    onGameStateChanged?.call(GameState.gameOver);

    // Visual feedback
    ball.setExpression(BallExpression.dizzy);
    cameraController.shake(intensity: 15);

    // Particle explosion
    particleSystem.emitExplosion(
      ball.center,
      NeonTheme.obstacleDanger,
      count: 30,
    );
  }

  void _collectItem(CollectibleComponent collectible) {
    if (collectible.isCollected) return;

    collectible.collect();
    score += collectible.value;
    combo++;
    comboTimer = GameConfig.comboTimeout;

    // Apply combo multiplier
    if (combo > 1) {
      score += (collectible.value * (combo - 1) * 0.5).toInt();
    }

    // Visual feedback
    ball.setExpression(BallExpression.excited);
    particleSystem.emitCollect(
      collectible.position +
          Vector2(collectible.itemRadius, collectible.itemRadius),
      collectible.getColorForType(),
    );
    particleSystem.emitSparkle(
      collectible.position +
          Vector2(collectible.itemRadius, collectible.itemRadius),
      collectible.getColorForType(),
    );
  }

  void _updateCombo(double dt) {
    if (combo > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) {
        combo = 0;
      }
    }
  }

  void _updateParticles() {
    // Emit trail particles when moving
    if (velocity.abs() > 50) {
      _particleFrameCounter++;
      if (_particleFrameCounter >= VisualConstants.trailParticlesPerFrame) {
        _particleFrameCounter = 0;
        particleSystem.emitTrail(ball.center, NeonTheme.ballGlow);
      }
    }
  }

  void _respawnBall() {
    ball.x = 50;
    final respawnTrackY = track.getTrackTopY(ball.x);
    if (respawnTrackY != null) {
      ball.y = respawnTrackY - ball.radius - PhysicsConstants.ballHoverHeight;
      verticalVelocity = 0;
      velocity = 0;
      isOnGround = true;
      ball.setExpression(BallExpression.happy);
      combo = 0;
    }
  }

  /// Start the game
  void startGame() {
    gameState = GameState.playing;
    onGameStateChanged?.call(GameState.playing);
  }

  /// Pause the game
  void pauseGame() {
    if (gameState == GameState.playing) {
      gameState = GameState.paused;
      onGameStateChanged?.call(GameState.paused);
    }
  }

  /// Resume the game
  void resumeGame() {
    if (gameState == GameState.paused) {
      gameState = GameState.playing;
      onGameStateChanged?.call(GameState.playing);
    }
  }

  /// Restart the game from scratch
  void restartGame() {
    // Reset game state
    score = 0;
    distance = 0;
    combo = 0;
    comboTimer = 0;
    velocity = 0;
    verticalVelocity = 0;
    direction = 0;
    isOnGround = true;
    airBounceCount = 0; // Reset bounce counter

    // Reset ball position
    final initialX = screenWidth / 2;
    final initialTrackY = track.getTrackTopY(initialX);
    ball.position = Vector2(
      initialX,
      (initialTrackY ?? 0) - ball.radius - PhysicsConstants.ballHoverHeight,
    );
    ball.setExpression(BallExpression.happy);

    // Reset collectibles
    for (final collectible in collectibles) {
      collectible.isCollected = false;
    }

    // Reset camera
    final initialCameraX = screenWidth * 0.5;
    final initialCameraY = baseY - (screenHeight * 0.4);
    cameraController.initialize(Vector2(initialCameraX, initialCameraY));

    // Start game
    gameState = GameState.playing;
    onGameStateChanged?.call(GameState.playing);
  }
}
