import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'ball_game.dart';

void main() {
  final game = BallGame();
  runApp(
    GameWidget(
      game: game,
      overlayBuilderMap: {
        'controls': (context, _) => GameControls(game),
      },
      initialActiveOverlays: const ['controls'],
    ),
  );
}

class GameControls extends StatefulWidget {
  final BallGame game;

  const GameControls(this.game, {super.key});

  @override
  State<GameControls> createState() => _GameControlsState();
}

class _GameControlsState extends State<GameControls> {
  int tapCount = 0;

  void handleJumpTap() {
    tapCount++;

    if (tapCount == 1) {
      // Wait for potential second tap
      Future.delayed(const Duration(milliseconds: 300), () {
        if (tapCount == 1) {
          // Single tap - normal jump
          widget.game.jump();
        }
        tapCount = 0;
      });
    } else if (tapCount == 2) {
      // Double tap - high jump
      widget.game.doubleJump();
      tapCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Jump button (up arrow) with double-tap support
            GestureDetector(
              onTap: handleJumpTap,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_up,
                  size: 40,
                  color: Colors.black,
                ),
              ),
            ),
            // Left and Right buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTapDown: (_) => widget.game.moveLeft(),
                  onTapUp: (_) => widget.game.stop(),
                  onTapCancel: () => widget.game.stop(),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_left,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTapDown: (_) => widget.game.moveRight(),
                  onTapUp: (_) => widget.game.stop(),
                  onTapCancel: () => widget.game.stop(),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_right,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
