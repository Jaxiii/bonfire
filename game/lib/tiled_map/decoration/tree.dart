import 'package:bonfire/bonfire.dart';

import '../dungeon_map.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 03/06/22

double getSizeByTileSize(double size) {
  return size * (DungeonMap.tileSize / 16);
}

class Tree extends GameDecoration with ObjectCollision {
  Tree(Vector2 position)
      : super.withSprite(
          sprite: Sprite.load('tile_random/tree.png'),
          position: position,
          size: Vector2(
            getSizeByTileSize(64),
            getSizeByTileSize(48),
          ),
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(getSizeByTileSize(32), getSizeByTileSize(16)),
            align: Vector2(
              getSizeByTileSize(16),
              getSizeByTileSize(32),
            ),
          ),
        ],
      ),
    );
  }
}
