import 'package:flutter/material.dart';

/// Game physics constants
class PhysicsConstants {
  // Horizontal movement
  static const double maxSpeed = 400.0;
  static const double acceleration = 800.0;
  static const double friction = 400.0;

  // Vertical movement
  static const double gravity = 1000.0;
  static const double jumpPower = 500.0;
  static const double bouncePower = 600.0;

  // Ball properties
  static const double ballRadius = 18.0;
  static const double ballHoverHeight = 13.0;

  // Collision
  static const double groundTolerance = 2.0;
  static const double vibrationDamping = 0.85;

  // Bounce physics
  static const double bounceEnergyLoss = 0.7; // 70% energy retained
  static const double minBounceVelocity = 50.0;
}

/// Visual effect constants
class VisualConstants {
  // Particle system
  static const int maxParticles = 200;
  static const double particleLifetime = 1.0;
  static const int trailParticlesPerFrame = 2;

  // Animation durations
  static const double expressionChangeDuration = 0.3;
  static const double squashStretchDuration = 0.15;
  static const double screenShakeDuration = 0.2;

  // Camera
  static const double cameraEasing = 0.1;
  static const double cameraLookAhead = 100.0;
  static const double screenShakeIntensity = 8.0;

  // UI
  static const double uiPadding = 20.0;
  static const double scoreFontSize = 32.0;
}

/// Neon theme colors
class NeonTheme {
  // Track colors
  static const Color trackPrimary = Color(0xFF00F5FF); // Cyan
  static const Color trackSecondary = Color(0xFFFF00FF); // Magenta
  static const Color trackGlow = Color(0xFF00FFFF);

  // Ball colors
  static const Color ballPrimary = Color(0xFFFF0080); // Hot pink
  static const Color ballGlow = Color(0xFFFF00FF);

  // Particle colors
  static const Color particleCyan = Color(0xFF00F5FF);
  static const Color particleMagenta = Color(0xFFFF00FF);
  static const Color particleYellow = Color(0xFFFFFF00);
  static const Color particleWhite = Color(0xFFFFFFFF);

  // Obstacle colors
  static const Color obstacleDanger = Color(0xFFFF0000);
  static const Color obstacleWarning = Color(0xFFFFAA00);

  // Collectible colors
  static const Color coinGold = Color(0xFFFFD700);
  static const Color starWhite = Color(0xFFFFFFFF);
  static const Color gemPurple = Color(0xFFAA00FF);

  // Background
  static const Color bgDark = Color(0xFF0A0A1A);
  static const Color bgMid = Color(0xFF1A1A3A);
  static const Color bgLight = Color(0xFF2A2A4A);
}

/// Game configuration
class GameConfig {
  // Track settings
  static const double trackWidth = 20000.0; // Extended for longer gameplay
  static const double trackHeight = 40.0;

  // Difficulty settings
  static const Map<String, Map<String, dynamic>> difficulty = {
    'easy': {'obstacleCount': 5, 'collectibleCount': 20, 'gapCount': 3},
    'medium': {'obstacleCount': 10, 'collectibleCount': 30, 'gapCount': 5},
    'hard': {'obstacleCount': 15, 'collectibleCount': 40, 'gapCount': 8},
  };

  // Scoring
  static const int coinValue = 10;
  static const int starValue = 50;
  static const int gemValue = 100;
  static const double comboMultiplier = 1.5;
  static const double comboTimeout = 2.0;
}
