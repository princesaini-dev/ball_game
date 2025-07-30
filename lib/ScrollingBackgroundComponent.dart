import 'package:flame/components.dart';
import 'package:flame/game.dart';

class ScrollingBackgroundComponent extends Component {
  final double gameWidth;
  final double gameHeight;
  // late SpriteComponent background1;
  // late SpriteComponent background2;
  double backgroundWidth = 0;

  ScrollingBackgroundComponent({
    required this.gameWidth,
    required this.gameHeight,
  });

  @override
  Future<void> onLoad() async {
    // Load the background sprite
    final backgroundSprite = await Sprite.load('background.jpg');

    // Calculate background width maintaining aspect ratio
    final imageSize = backgroundSprite.originalSize;
    final aspectRatio = imageSize.x / imageSize.y;
    backgroundWidth = gameHeight * aspectRatio;

    // Create two background sprites for seamless looping
    // background1 = SpriteComponent(
    //   sprite: backgroundSprite,
    //   size: Vector2(backgroundWidth, gameHeight),
    //   position: Vector2(0, 0),
    // );
    //
    // background2 = SpriteComponent(
    //   sprite: backgroundSprite,
    //   size: Vector2(backgroundWidth, gameHeight),
    //   position: Vector2(backgroundWidth, 0),
    // );
    //
    // add(background1);
    // add(background2);
  }

  void updateBackgroundPosition(double cameraX) {
    // Move backgrounds based on camera position (parallax effect)
    final parallaxSpeed = 0.3; // Background moves slower than camera
    final backgroundOffset = cameraX * parallaxSpeed;

    // Calculate positions for seamless looping
    final bg1X = (backgroundOffset % (backgroundWidth * 2));
    final bg2X = bg1X - backgroundWidth;

    // background1.position.x = -bg1X;
    // background2.position.x = -bg2X;
    //
    // // Swap backgrounds when they go off screen for seamless loop
    // if (background1.position.x <= -backgroundWidth) {
    //   background1.position.x = background2.position.x + backgroundWidth;
    // }
    // if (background2.position.x <= -backgroundWidth) {
    //   background2.position.x = background1.position.x + backgroundWidth;
    // }
  }
}
