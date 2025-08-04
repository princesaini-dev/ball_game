import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'ball_game.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ball Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BallGame game;

  @override
  void initState() {
    super.initState();
    game = BallGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<BallGame>.controlled(
            gameFactory: () => game,
          ),
          // Control buttons overlay
          //_buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned.fill(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left button
                _buildControlButton(
                  icon: Icons.keyboard_arrow_left,
                  onPressStart: () => game.moveLeft(),
                  onPressEnd: () => game.stop(),
                  label: 'Left',
                ),
                // Bounce button (immediate response)
                _buildControlButton(
                  icon: Icons.sports_volleyball,
                  onPressed: () => game.bounce(), // Immediate bounce
                  label: 'Bounce',
                  color: Colors.orange,
                ),
                // Right button
                _buildControlButton(
                  icon: Icons.keyboard_arrow_right,
                  onPressStart: () => game.moveRight(),
                  onPressEnd: () => game.stop(),
                  label: 'Right',
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onPressed,
    VoidCallback? onPressStart,
    VoidCallback? onPressEnd,
    VoidCallback? onLongPress,
    required String label,
    Color? color,
  }) {
    return GestureDetector(
      onTapDown: onPressStart != null ? (_) => onPressStart() : null,
      onTapUp: onPressEnd != null ? (_) => onPressEnd() : null,
      onTapCancel: onPressEnd,
      onTap: onPressed,
      onLongPress: onLongPress,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: (color ?? Colors.blue).withOpacity(0.8),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
