import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/game_constants.dart';

/// Particle types for different visual effects
enum ParticleType { trail, explosion, sparkle, collect, dust }

/// Individual particle with physics and rendering
class Particle {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double size;
  double lifetime;
  double maxLifetime;
  ParticleType type;
  double rotation;
  double rotationSpeed;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.maxLifetime,
    required this.type,
  }) : lifetime = 0,
       rotation = 0,
       rotationSpeed = (Random().nextDouble() - 0.5) * 10;

  bool get isDead => lifetime >= maxLifetime;

  double get alpha => 1.0 - (lifetime / maxLifetime);

  void update(double dt) {
    lifetime += dt;
    position += velocity * dt;
    rotation += rotationSpeed * dt;

    // Apply gravity to certain particle types
    if (type == ParticleType.explosion || type == ParticleType.dust) {
      velocity.y += PhysicsConstants.gravity * 0.3 * dt;
    }

    // Fade velocity over time
    velocity *= 0.98;
  }
}

/// Particle system component for managing and rendering particles
class ParticleSystem extends Component {
  final List<Particle> _particles = [];
  final Random _random = Random();
  late Paint _particlePaint;

  ParticleSystem() {
    _particlePaint = Paint()..style = PaintingStyle.fill;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update all particles
    for (final particle in _particles) {
      particle.update(dt);
    }

    // Remove dead particles
    _particles.removeWhere((p) => p.isDead);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (final particle in _particles) {
      _renderParticle(canvas, particle);
    }
  }

  void _renderParticle(Canvas canvas, Particle particle) {
    final alpha = particle.alpha;
    _particlePaint.color = particle.color.withValues(alpha: alpha);

    canvas.save();
    canvas.translate(particle.position.x, particle.position.y);
    canvas.rotate(particle.rotation);

    switch (particle.type) {
      case ParticleType.trail:
      case ParticleType.dust:
        canvas.drawCircle(Offset.zero, particle.size, _particlePaint);
        break;

      case ParticleType.explosion:
        // Draw with glow effect
        _particlePaint.color = particle.color.withValues(alpha: alpha * 0.3);
        canvas.drawCircle(Offset.zero, particle.size * 2, _particlePaint);
        _particlePaint.color = particle.color.withValues(alpha: alpha);
        canvas.drawCircle(Offset.zero, particle.size, _particlePaint);
        break;

      case ParticleType.sparkle:
        // Draw star shape
        _drawStar(canvas, particle.size, _particlePaint);
        break;

      case ParticleType.collect:
        // Draw with outer glow
        _particlePaint.color = particle.color.withValues(alpha: alpha * 0.5);
        canvas.drawCircle(Offset.zero, particle.size * 1.5, _particlePaint);
        _particlePaint.color = particle.color.withValues(alpha: alpha);
        canvas.drawCircle(Offset.zero, particle.size, _particlePaint);
        break;
    }

    canvas.restore();
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    const points = 5;
    const angleStep = pi * 2 / points;

    for (int i = 0; i < points * 2; i++) {
      final angle = i * angleStep / 2 - pi / 2;
      final radius = i.isEven ? size : size * 0.5;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Emit a trail particle behind the ball
  void emitTrail(Vector2 position, Color color) {
    if (_particles.length >= VisualConstants.maxParticles) return;

    final velocity = Vector2(
      (_random.nextDouble() - 0.5) * 20,
      (_random.nextDouble() - 0.5) * 20,
    );

    _particles.add(
      Particle(
        position: position.clone(),
        velocity: velocity,
        color: color,
        size: 3 + _random.nextDouble() * 2,
        maxLifetime: 0.5,
        type: ParticleType.trail,
      ),
    );
  }

  /// Emit explosion particles on impact
  void emitExplosion(Vector2 position, Color color, {int count = 15}) {
    for (int i = 0; i < count; i++) {
      if (_particles.length >= VisualConstants.maxParticles) break;

      final angle = (i / count) * pi * 2;
      final speed = 100 + _random.nextDouble() * 100;
      final velocity = Vector2(cos(angle) * speed, sin(angle) * speed);

      _particles.add(
        Particle(
          position: position.clone(),
          velocity: velocity,
          color: color,
          size: 4 + _random.nextDouble() * 4,
          maxLifetime: 0.6 + _random.nextDouble() * 0.4,
          type: ParticleType.explosion,
        ),
      );
    }
  }

  /// Emit sparkle particles for collectibles
  void emitSparkle(Vector2 position, Color color, {int count = 8}) {
    for (int i = 0; i < count; i++) {
      if (_particles.length >= VisualConstants.maxParticles) break;

      final angle = (i / count) * pi * 2;
      final speed = 50 + _random.nextDouble() * 50;
      final velocity = Vector2(cos(angle) * speed, sin(angle) * speed);

      _particles.add(
        Particle(
          position: position.clone(),
          velocity: velocity,
          color: color,
          size: 3 + _random.nextDouble() * 2,
          maxLifetime: 0.8,
          type: ParticleType.sparkle,
        ),
      );
    }
  }

  /// Emit collection effect particles
  void emitCollect(Vector2 position, Color color) {
    for (int i = 0; i < 10; i++) {
      if (_particles.length >= VisualConstants.maxParticles) break;

      final angle = _random.nextDouble() * pi * 2;
      final speed = 80 + _random.nextDouble() * 80;
      final velocity = Vector2(
        cos(angle) * speed,
        sin(angle) * speed - 100, // Upward bias
      );

      _particles.add(
        Particle(
          position: position.clone(),
          velocity: velocity,
          color: color,
          size: 4 + _random.nextDouble() * 3,
          maxLifetime: 1.0,
          type: ParticleType.collect,
        ),
      );
    }
  }

  /// Emit dust particles on ground contact
  void emitDust(Vector2 position, {int count = 5}) {
    for (int i = 0; i < count; i++) {
      if (_particles.length >= VisualConstants.maxParticles) break;

      final velocity = Vector2(
        (_random.nextDouble() - 0.5) * 60,
        -_random.nextDouble() * 40,
      );

      _particles.add(
        Particle(
          position: position.clone(),
          velocity: velocity,
          color: Colors.white.withValues(alpha: 0.6),
          size: 2 + _random.nextDouble() * 2,
          maxLifetime: 0.4,
          type: ParticleType.dust,
        ),
      );
    }
  }

  int get particleCount => _particles.length;
}
