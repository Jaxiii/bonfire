import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../network/message.dart';
import '../network/message_service.dart';
import '../shared/interface/bar_life_widget.dart';
import '../shared/interface/knight_interface.dart';
import '../shared/other/other_player.dart';
import '../shared/player/knight.dart';
import '../utils/map_generator.dart';
import 'dungeon_map.dart';

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
/// on 31/05/22

class RandomMapGame extends StatefulWidget {
  final Vector2 size;
  final double seed;
  final String id;
  final MessageService messageService;

  const RandomMapGame(
      {Key? key,
      required this.size,
      required this.seed,
      required this.id,
      required this.messageService})
      : super(key: key);

  @override
  State<RandomMapGame> createState() => _RandomMapGameState();
}

class _RandomMapGameState extends State<RandomMapGame> {
  MapGenerator? _mapGenerator;
  late final GameController gameController;
  late final MessageService messageService = widget.messageService;

  late final String id = widget.id;

  @override
  void initState() {
    gameController = BonfireInjector.instance.get<GameController>();
    messageService.onListen(ActionMessage.enemyInvocation, _addEnemy);
    messageService.onListen(
        ActionMessage.previouslyEnemyConnected, _addEnemyBeforeYourLogin);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addEnemy(Message message) {
    final enemy = OtherPlayer(
      id: message.idPlayer,
      position: message.position!,
      direction: message.direction!.toDirection(),
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
        direction: message.direction!.toDirection(),
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
        _mapGenerator ??= MapGenerator(
          widget.size,
          DungeonMap.tileSize,
          widget.seed,
          id,
        );
        return FutureBuilder<MapGenerated>(
          future: _mapGenerator!.buildMap(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Material(
                color: Colors.black,
                child: Center(
                  child: Text(
                    'Generation nouse...',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }
            MapGenerated result = snapshot.data!;
            return BonfireWidget(
              onReady: (gameRef) => messageService.send(
                Message(
                  idPlayer: id,
                  action: ActionMessage.enemyInvocation,
                  level: 'dg',
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
                  keyboardDirectionalType:
                      KeyboardDirectionalType.wasdAndArrows,
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
              map: result.map,
              components: result.components,
              delayToHideProgress: const Duration(milliseconds: 500),
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
      },
    );
  }
}
