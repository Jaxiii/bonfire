import 'package:bonfire/bonfire.dart';
import 'package:example/network/message_service.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:example/shared/util/player_sprite_sheet.dart';

import '../../network/message.dart';
import '../util/enemy_sprite_sheet.dart';
import 'other_player.dart';

class OtherPlayerController extends StateController<OtherPlayer> {
  final MessageService messageService;
  bool isIdle = true;
  Direction direction = Direction.right;

  OtherPlayerController({
    required this.messageService,
  });

  @override
  void update(double dt, OtherPlayer component) {
    moveLocal();
  }

  moveLocal() {
    if (isIdle) {
      component!.idle();
      return;
    }
    double speed = component!.speed;
    double speedDiagonal = (speed * Movement.REDUCTION_SPEED_DIAGONAL);
    switch (direction) {
      case Direction.left:
        component!.moveLeft(speed);
        break;
      case Direction.downLeft:
        component!.moveDownLeft(speedDiagonal, speedDiagonal);
        break;
      case Direction.upLeft:
        component!.moveUpLeft(speedDiagonal, speedDiagonal);
        break;
      case Direction.right:
        component!.moveRight(speed);
        break;
      case Direction.downRight:
        component!.moveDownRight(speedDiagonal, speedDiagonal);
        break;
      case Direction.upRight:
        component!.moveUpRight(speedDiagonal, speedDiagonal);
        break;
      case Direction.down:
        component!.moveDown(speed);
        break;
      case Direction.up:
        component!.moveUp(speed);
        break;
      default:
        component!.idle();
        break;
    }
  }

  @override
  void onReady(OtherPlayer component) {
    messageService.onListen(ActionMessage.move, moveServer);
    messageService.onListen(ActionMessage.idle, idleServer);
    messageService.onListen(ActionMessage.attack, attackServer);
    messageService.onListen(ActionMessage.disconnect, disconnectServer);
    super.onReady(component);
  }

  void attackServer(Message message) {
    if (component != null && message.idPlayer == component!.id) {
      component!.simpleAttackMeleeByDirection(
        damage: 10,
        size: Vector2(40, 40),
        direction: direction,
        attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
        animationRight: CommonSpriteSheet.blackAttackEffectRight,
        withPush: true,
      );
    }
  }

  void disconnectServer(Message message) {
    if (component != null && message.idPlayer == component!.id) {
      component!.die();
    }
  }

  void idleServer(Message message) {
    if (component != null && message.idPlayer == component!.id) {
      isIdle = true;
      component!.lastDirection = message.direction.toDirection();
      direction = message.direction.toDirection();
    }
  }

  void moveServer(Message message) {
    if (component != null && message.idPlayer == component!.id) {
      isIdle = false;
      component!.position = message.position!;
      direction = message.direction.toDirection();
    }
  }
}

//92e31e80-9bfb-1cca-9cfd-974838f8cb67 - X
//fb52ef80-9c3d-1cca-b96c-0595266ade97
