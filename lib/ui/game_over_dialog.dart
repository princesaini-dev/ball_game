import 'package:flutter/material.dart';
import '../config/game_constants.dart';

/// Game over dialog with neon theme
class GameOverDialog extends StatelessWidget {
  final int finalScore;
  final double finalDistance;
  final VoidCallback onRestart;

  const GameOverDialog({
    super.key,
    required this.finalScore,
    required this.finalDistance,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              NeonTheme.bgDark.withValues(alpha: 0.95),
              NeonTheme.bgMid.withValues(alpha: 0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NeonTheme.trackGlow, width: 3),
          boxShadow: [
            BoxShadow(
              color: NeonTheme.trackGlow.withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Game Over Title
            Text(
              'GAME OVER',
              style: TextStyle(
                color: NeonTheme.obstacleDanger,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    color: NeonTheme.obstacleDanger.withValues(alpha: 0.8),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Score Display
            _buildStatRow(
              icon: Icons.stars,
              label: 'SCORE',
              value: finalScore.toString(),
              color: NeonTheme.coinGold,
            ),

            const SizedBox(height: 15),

            // Distance Display
            _buildStatRow(
              icon: Icons.straighten,
              label: 'DISTANCE',
              value: '${finalDistance.toInt()}m',
              color: NeonTheme.trackPrimary,
            ),

            const SizedBox(height: 40),

            // Restart Button
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: NeonTheme.trackGlow, width: 3),
                ),
                shadowColor: NeonTheme.trackGlow,
                elevation: 10,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      NeonTheme.trackPrimary.withValues(alpha: 0.3),
                      NeonTheme.trackSecondary.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'RESTART',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(color: NeonTheme.trackGlow, blurRadius: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.8), blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
