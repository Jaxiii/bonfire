import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/other_sprite_sheet.dart';

import '../../tiled_map/dungeon_map.dart';
import 'other_player_controller.dart';

class OtherPlayer extends SimpleEnemy
    with ObjectCollision, UseStateController<OtherPlayerController> {
  final String id;

  OtherPlayer({
    required this.id,
    required Vector2 position,
    required Direction direction,
  }) : super(
          initDirection: direction,
          position: position,
          size: Vector2.all(DungeonMap.tileSize),
          animation: SimpleDirectionAnimation(
            idleRight: EnemySpriteSheet.idleRight,
            runRight: EnemySpriteSheet.runRight,
            idleLeft: EnemySpriteSheet.idleLeft,
            runLeft: EnemySpriteSheet.runLeft,
          ),
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(20, 20),
            align: Vector2(6, 15),
          ),
        ],
      ),
    );
  }

  @override
  void die() async {
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: position,
        size: Vector2.all(DungeonMap.tileSize),
      ),
    );
    super.die();
  }
}
