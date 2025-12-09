import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/game.dart';
import 'ball_game_enhanced.dart';
import 'ui/game_ui_overlay.dart';
import 'ui/start_screen.dart';
import 'ui/game_over_dialog.dart';
import 'config/game_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Ball Game',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BallGame game;
  GameState _currentState = GameState.start;

  @override
  void initState() {
    super.initState();
    game = BallGame();

    // Listen to game state changes
    game.onGameStateChanged = (newState) {
      setState(() {
        _currentState = newState;
      });

      // Show game over dialog
      if (newState == GameState.gameOver) {
        _showGameOverDialog();
      }
    };
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => GameOverDialog(
            finalScore: game.score,
            finalDistance: game.distance,
            onRestart: () {
              Navigator.of(context).pop();
              game.restartGame();
            },
          ),
    );
  }

  void _handlePause() {
    if (_currentState == GameState.playing) {
      game.pauseGame();
      _showPauseDialog();
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'PAUSED',
              style: TextStyle(color: Colors.white, fontSize: 32),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    game.resumeGame();
                  },
                  child: const Text('RESUME'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    game.restartGame();
                  },
                  child: const Text('RESTART'),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game widget
          GameWidget<BallGame>.controlled(gameFactory: () => game),

          // Start screen overlay
          if (_currentState == GameState.start)
            StartScreen(
              onStart: () {
                game.startGame();
              },
            ),

          // Game UI overlay (only show when playing)
          if (_currentState == GameState.playing)
            ValueListenableBuilder<int>(
              valueListenable: _ScoreNotifier(game),
              builder: (context, _, __) {
                return GameUIOverlay(
                  score: game.score,
                  distance: game.distance,
                  combo: game.combo,
                  onPause: _handlePause,
                  // Only show debug toggle in debug mode
                  onDebugToggle:
                      kDebugMode
                          ? () {
                            setState(() {
                              game.collisionEnabled = !game.collisionEnabled;
                            });
                          }
                          : null,
                  collisionEnabled: game.collisionEnabled,
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Helper to rebuild UI when game state changes
class _ScoreNotifier extends ValueNotifier<int> {
  final BallGame game;

  _ScoreNotifier(this.game) : super(0) {
    _startListening();
  }

  void _startListening() {
    // Update every frame
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 16));
      if (value != game.score) {
        value = game.score;
      }
      return true;
    });
  }
}
