import 'package:bonfire/bonfire.dart';
import 'package:example/shared/player/knight.dart';
import 'package:flutter/services.dart';
import '../../network/message.dart';
import '../../network/message_service.dart';

class PlayerController extends StateController<Knight> {
  final MessageService messageService;
  double stamina = 100;
  double attack = 20;
  bool canShowEmote = true;
  bool showedDialog = false;
  bool executingRangeAttack = false;
  double radAngleRangeAttack = 0;
  PlayerController({
    required this.messageService,
  });

  @override
  void update(double dt, Knight component) {}

  onAttack() {
    messageService.send(Message(
      idPlayer: component!.id,
      action: ActionMessage.attack,
      direction: DirectionMessage.direction(component!.lastDirection),
    ));
  }

  onMove(double speed, Direction direction) {
    if (speed > 0) {
      messageService.send(
        Message(
          idPlayer: component!.id,
          action: ActionMessage.move,
          direction: DirectionMessage.direction(direction),
          position: Vector2(component!.x, component!.y),
        ),
      );
    } else {
      idleAction(direction);
    }
  }

  void idleAction(Direction direction) {
    messageService.send(
      Message(
        idPlayer: component!.id,
        action: ActionMessage.idle,
        direction: DirectionMessage.direction(direction),
        position: Vector2(component!.x, component!.y),
      ),
    );
  }

  void handleJoystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN) {
      if (event.id == LogicalKeyboardKey.space.keyId ||
          event.id == PlayerAttackType.attackMelee) {
        if (stamina > 15) {
          _decrementStamina(15);
          component?.execMeleeAttack(attack);
        }
      }
    }

    if (event.id == PlayerAttackType.attackRange) {
      if (event.event == ActionEvent.MOVE) {
        executingRangeAttack = true;
        radAngleRangeAttack = event.radAngle;
      }
      if (event.event == ActionEvent.UP) {
        executingRangeAttack = false;
      }
      component?.execEnableBGRangeAttack(executingRangeAttack, event.radAngle);
    }
  }

  void _verifyStamina(double dt) {
    if (stamina < 100 &&
        component?.checkInterval('INCREMENT_STAMINA', 100, dt) == true) {
      stamina += 2;
      if (stamina > 100) {
        stamina = 100;
      }
    }
    component?.updateStamina(stamina);
  }

  void _decrementStamina(int i) {
    stamina -= i;
    if (stamina < 0) {
      stamina = 0;
    }
    component?.updateStamina(stamina);
  }

  void onReceiveDamage(double damage) {
    component?.execShowDamage(damage);
  }
}
