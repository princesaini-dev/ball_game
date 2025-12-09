import 'package:flutter/material.dart';
import '../config/game_constants.dart';

/// Game UI overlay with score, distance, and combo display
class GameUIOverlay extends StatelessWidget {
  final int score;
  final double distance;
  final int combo;
  final VoidCallback? onPause;
  final VoidCallback? onDebugToggle;
  final bool collisionEnabled;

  const GameUIOverlay({
    super.key,
    required this.score,
    required this.distance,
    required this.combo,
    this.onPause,
    this.onDebugToggle,
    this.collisionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Top bar with score and distance
          Positioned(
            top: VisualConstants.uiPadding,
            left: VisualConstants.uiPadding,
            right: VisualConstants.uiPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildScoreDisplay(), _buildDistanceDisplay()],
            ),
          ),

          // Combo indicator (center top)
          if (combo > 1)
            Positioned(
              top: VisualConstants.uiPadding + 60,
              left: 0,
              right: 0,
              child: _buildComboDisplay(),
            ),

          // Pause button (top right)
          Positioned(
            top: VisualConstants.uiPadding,
            right: VisualConstants.uiPadding,
            child: _buildPauseButton(),
          ),

          // Debug toggle button (top center) - only in debug mode
          if (onDebugToggle != null)
            Positioned(
              top: VisualConstants.uiPadding,
              left: 0,
              right: 0,
              child: Center(child: _buildDebugToggle()),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NeonTheme.trackPrimary.withValues(alpha: 0.3),
            NeonTheme.trackSecondary.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NeonTheme.trackGlow, width: 2),
        boxShadow: [
          BoxShadow(
            color: NeonTheme.trackGlow.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: NeonTheme.coinGold, size: 24),
          const SizedBox(width: 8),
          Text(
            score.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: VisualConstants.scoreFontSize,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: NeonTheme.trackGlow, blurRadius: 10)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NeonTheme.trackSecondary.withValues(alpha: 0.3),
            NeonTheme.trackPrimary.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NeonTheme.trackGlow, width: 2),
        boxShadow: [
          BoxShadow(
            color: NeonTheme.trackGlow.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.straighten, color: NeonTheme.trackPrimary, size: 24),
          const SizedBox(width: 8),
          Text(
            '${distance.toInt()}m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: NeonTheme.trackGlow, blurRadius: 10)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComboDisplay() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.2),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [NeonTheme.particleYellow, NeonTheme.particleMagenta],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: NeonTheme.particleYellow.withValues(alpha: 0.6),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'COMBO x$combo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPauseButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            NeonTheme.trackPrimary.withValues(alpha: 0.4),
            NeonTheme.trackSecondary.withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(color: NeonTheme.trackGlow, width: 2),
        boxShadow: [
          BoxShadow(
            color: NeonTheme.trackGlow.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.pause, color: Colors.white, size: 28),
        onPressed: onPause,
      ),
    );
  }

  Widget _buildDebugToggle() {
    return GestureDetector(
      onTap: onDebugToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              collisionEnabled
                  ? Colors.red.withValues(alpha: 0.8)
                  : Colors.green.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: collisionEnabled ? Colors.redAccent : Colors.greenAccent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (collisionEnabled ? Colors.red : Colors.green).withValues(
                alpha: 0.5,
              ),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              collisionEnabled ? Icons.shield : Icons.shield_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              collisionEnabled ? 'COLLISION: ON' : 'COLLISION: OFF',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
