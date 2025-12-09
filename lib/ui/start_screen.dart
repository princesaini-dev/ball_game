import 'package:flutter/material.dart';
import '../config/game_constants.dart';

/// Start screen with play button
class StartScreen extends StatelessWidget {
  final VoidCallback onStart;

  const StartScreen({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NeonTheme.bgDark.withValues(alpha: 0.9),
            NeonTheme.bgMid.withValues(alpha: 0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Title
            Text(
              'NEON',
              style: TextStyle(
                color: NeonTheme.trackPrimary,
                fontSize: 72,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                shadows: [
                  Shadow(
                    color: NeonTheme.trackPrimary.withValues(alpha: 0.8),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
            Text(
              'BALL',
              style: TextStyle(
                color: NeonTheme.trackSecondary,
                fontSize: 72,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                shadows: [
                  Shadow(
                    color: NeonTheme.trackSecondary.withValues(alpha: 0.8),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Play Button
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 25,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                  side: BorderSide(color: NeonTheme.trackGlow, width: 4),
                ),
                shadowColor: NeonTheme.trackGlow,
                elevation: 15,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      NeonTheme.trackPrimary.withValues(alpha: 0.4),
                      NeonTheme.trackSecondary.withValues(alpha: 0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                    const SizedBox(width: 15),
                    Text(
                      'START',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(color: NeonTheme.trackGlow, blurRadius: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Instructions
            Text(
              'Use Arrow Keys to Move',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Press ↑ to Bounce',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
