import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/tiled_map/dungeon_map.dart';
import 'package:example/shared/decoration/barrel_dragable.dart';
import 'package:example/shared/decoration/chest.dart';
import 'package:example/shared/decoration/spikes.dart';
import 'package:example/shared/decoration/torch.dart';
import 'package:example/shared/enemy/goblin.dart';
import 'package:example/shared/interface/bar_life_widget.dart';
import 'package:example/shared/interface/knight_interface.dart';
import 'package:example/shared/npc/critter/critter.dart';
import 'package:example/shared/npc/wizard/wizard.dart';
import 'package:example/shared/player/knight.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../network/message.dart';
import '../network/message_service.dart';
import '../shared/decoration/column.dart';
import '../shared/other/other_player.dart';
import '../utils/enums/map_id_enum.dart';
import '../utils/enums/show_in_enum.dart';
import '../utils/sensors/exit_map_sensor.dart';
import 'multi_scenario2.dart';

class GameTiledMap2 extends StatefulWidget {
  final int map;
  final ShowInEnum showInEnum;

  const GameTiledMap2({Key? key, this.map = 1, required this.showInEnum})
      : super(key: key);

  @override
  State<GameTiledMap2> createState() => _GameTiledMapState();
}

class _GameTiledMapState extends State<GameTiledMap2> {
  late final GameController gameController;
  late final MessageService messageService;

  late final String id;

  @override
  void initState() {
    id = const Uuid().v1();
    gameController = BonfireInjector.instance.get<GameController>();
    messageService = BonfireInjector.instance.get<MessageService>();
    messageService.init();
    messageService.onListen(ActionMessage.enemyInvocation, _addEnemy);
    messageService.onListen(
        ActionMessage.previouslyEnemyConnected, _addEnemyBeforeYourLogin);
    super.initState();
  }

  @override
  void dispose() {
    messageService.dispose();
    super.dispose();
  }

  void _addEnemy(Message message) {
    print('message.idPlayer');
    print(message.idPlayer);
    final enemy = OtherPlayer(
      id: message.idPlayer,
      position: message.position!,
      direction: message.direction.toDirection(),
    );
    gameController.addGameComponent(enemy);
    messageService.send(
      Message(
        idPlayer: id,
        action: ActionMessage.previouslyEnemyConnected,
        direction: DirectionMessage.direction(
          gameController.player!.lastDirection,
        ),
        position: gameController.player!.position,
      ),
    );
  }

  void _addEnemyBeforeYourLogin(Message message) {
    final hasEnemy = gameController.gameRef
        .componentsByType<OtherPlayer>()
        .any((element) => element.id == message.idPlayer);
    if (!hasEnemy) {
      final enemy = OtherPlayer(
        id: message.idPlayer,
        position: message.position!,
        direction: message.direction.toDirection(),
      );
      gameController.addGameComponent(enemy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        DungeonMap.tileSize = max(constraints.maxHeight, constraints.maxWidth) /
            (kIsWeb ? 25 : 22);
        return BonfireWidget(
          onReady: (gameRef) => messageService.send(
            Message(
              idPlayer: id,
              action: ActionMessage.enemyInvocation,
              direction: DirectionMessage.right,
              position: Vector2(
                gameRef.player!.position.x,
                gameRef.player!.position.y,
              ),
            ),
          ),
          gameController: gameController,
          joystick: Joystick(
            keyboardConfig: KeyboardConfig(
              keyboardDirectionalType: KeyboardDirectionalType.wasdAndArrows,
              acceptedKeys: [
                LogicalKeyboardKey.space,
              ],
            ),
            directional: JoystickDirectional(
              spriteBackgroundDirectional: Sprite.load(
                'joystick_background.png',
              ),
              spriteKnobDirectional: Sprite.load('joystick_knob.png'),
              size: 100,
              isFixed: false,
            ),
            actions: [
              JoystickAction(
                actionId: PlayerAttackType.attackMelee,
                sprite: Sprite.load('joystick_atack.png'),
                align: JoystickActionAlign.BOTTOM_RIGHT,
                size: 80,
                margin: const EdgeInsets.only(bottom: 50, right: 50),
              ),
              JoystickAction(
                actionId: PlayerAttackType.attackRange,
                sprite: Sprite.load('joystick_atack_range.png'),
                spriteBackgroundDirection: Sprite.load(
                  'joystick_background.png',
                ),
                enableDirection: true,
                size: 50,
                margin: const EdgeInsets.only(bottom: 50, right: 160),
              )
            ],
          ),
          player: Knight(
            Vector2((8 * DungeonMap.tileSize), (5 * DungeonMap.tileSize)),
            id: id,
          ),
          interface: KnightInterface(),
          map: WorldMapByTiled(
            'tiled/map2.json',
            forceTileSize: Vector2(DungeonMap.tileSize, DungeonMap.tileSize),
            objectsBuilder: {
              'goblin': (properties) => Goblin(properties.position),
              'torch': (properties) => Torch(properties.position),
              'barrel': (properties) => BarrelDraggable(properties.position),
              'spike': (properties) => Spikes(properties.position),
              'column': (properties) => ColumnDecoration(properties.position),
              'chest': (properties) => Chest(properties.position),
              'critter': (properties) => Critter(properties.position),
              'wizard': (properties) => Wizard(properties.position),
              'sensorLeft': (properties) => ExitMapSensor(
                    'sensorLeft',
                    properties.position,
                    properties.size,
                    _exitMap,
                  ),
              'sensorRight': (properties) => ExitMapSensor(
                    'sensorRight',
                    properties.position,
                    properties.size,
                    _exitMap,
                  ),
            },
          ),
          lightingColorGame: Colors.black.withOpacity(0.7),
          overlayBuilderMap: {
            'barLife': (context, game) => const BarLifeWidget(),
            'miniMap': (context, game) => MiniMap(
                  game: game,
                  margin: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(10),
                  size: Vector2.all(
                    min(constraints.maxHeight, constraints.maxWidth) / 3,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
          },
          initialActiveOverlays: const [
            'barLife',
            'miniMap',
          ],
          cameraConfig: CameraConfig(
            smoothCameraEnabled: true,
            smoothCameraSpeed: 2,
          ),
        );
      },
    );
  }

  void _exitMap(String value) {
    if (value == 'sensorRight') {
      selectMap(MapBiomeId.biome2);
    }
  }
}
