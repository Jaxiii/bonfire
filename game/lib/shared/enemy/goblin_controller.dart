import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/network/message_service.dart';
import 'package:example/tiled_map/dungeon_map.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'goblin.dart';

class GoblinController extends StateController<Goblin> {
  double attack = 20;
  bool _seePlayerToAttackMelee = false;
  bool enableBehaviors = true;
  final _positionsToRespawn = [
    Vector2(32 * 4, 32 * 4),
    Vector2(32 * 16, 32 * 4),
    Vector2(32 * 4, 32 * 16),
    Vector2(32 * 16, 32 * 16),
  ];
  final _quantityRespawns = 2;

  @override
  void onReady(Goblin component) {
    BonfireInjector.instance
        .get<MessageService>()
        .onListen('SPAWN_ENEMY', (p0) => respawnMany());
    super.onReady(component);
  }

  void respawnMany() {
    final random = Random();
    final positions = List<Vector2>.from(_positionsToRespawn);
    int numberOfRespawn = _quantityRespawns;

    while (numberOfRespawn > 0) {
      final indexPosition = random.nextInt(positions.length);
      final position = positions[indexPosition];
      _respawn(position);
      positions.remove(position);
      numberOfRespawn -= 1;
    }
  }

  void _respawn(Vector2 position) {
    final hasGameRef = component?.hasGameRef ?? false;
    if (hasGameRef && !gameRef.camera.isMoving) {
      final goblin = Goblin(position);
      gameRef.add(goblin);
    }
  }

  @override
  void update(double dt, Goblin component) {
    if (!enableBehaviors) return;

    if (!gameRef.sceneBuilderStatus.isRunning) {
      _seePlayerToAttackMelee = false;

      component.seeAndMoveToPlayer(
        closePlayer: (player) {
          component.execAttack(attack);
        },
        observed: () {
          _seePlayerToAttackMelee = true;
        },
        radiusVision: DungeonMap.tileSize * 1.5,
      );

      if (!_seePlayerToAttackMelee) {
        component.seeAndMoveToAttackRange(
          minDistanceFromPlayer: DungeonMap.tileSize * 2,
          positioned: (p) {
            component.execAttackRange(attack);
          },
          radiusVision: DungeonMap.tileSize * 3,
          notObserved: () {
            component.runRandomMovement(
              dt,
              speed: component.speed / 2,
              maxDistance: (DungeonMap.tileSize * 3).toInt(),
            );
          },
        );
      }
    }
  }
}
