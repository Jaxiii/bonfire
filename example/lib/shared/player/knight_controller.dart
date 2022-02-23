import 'package:bonfire/bonfire.dart';
import 'package:example/shared/player/knight.dart';
import 'package:flutter/services.dart';

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
/// on 23/02/22
///

class KnightController extends GameComponentController<Knight> {
  double attack = 20;
  bool canShowEmote = true;
  bool showedDialog = false;
  bool executingRangeAttack = false;
  double radAngleRangeAttack = 0;

  @override
  void update(double dt) {
    if (component.isDead) return;
    if (component.checkInterval('seeEnemy', 250, dt)) {
      component.seeEnemy(
        radiusVision: component.width * 4,
        notObserved: _handleNotObserveEnemy,
        observed: (enemies) => _handleObserveEnemy(enemies.first),
      );
    }

    if (executingRangeAttack &&
        component.checkInterval('ATTACK_RANGE', 150, dt)) {
      if (component.stamina > 10) {
        _decrementStamina(10);
        component.execRangeAttack(radAngleRangeAttack, attack / 2);
      }
    }
    _verifyStamina(dt);
    super.update(dt);
  }

  void handleInteractJoystick(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN) {
      if (event.id == LogicalKeyboardKey.space.keyId ||
          event.id == PlayerAttackType.AttackMelee) {
        if (component.stamina > 15) {
          _decrementStamina(15);
          component.execMeleeAttack(attack);
        }
      }
    }

    if (event.id == PlayerAttackType.AttackRange) {
      if (event.event == ActionEvent.MOVE) {
        executingRangeAttack = true;
        radAngleRangeAttack = event.radAngle;
      }
      if (event.event == ActionEvent.UP) {
        executingRangeAttack = false;
      }
      component.execEnableBGRangeAttack(executingRangeAttack, event.radAngle);
    }
  }

  void _handleObserveEnemy(Enemy enemy) {
    if (canShowEmote) {
      canShowEmote = false;
      component.execShowEmote();
    }
    if (!showedDialog) {
      showedDialog = true;
      component.execShowTalk(enemy);
    }
  }

  void _handleNotObserveEnemy() {
    canShowEmote = true;
  }

  void _verifyStamina(double dt) {
    if (component.stamina < 100 &&
        component.checkInterval('INCREMENT_STAMINA', 100, dt)) {
      component.stamina += 2;
      if (component.stamina > 100) {
        component.stamina = 100;
      }
    }
  }

  void _decrementStamina(int i) {
    component.stamina -= i;
    if (component.stamina < 0) {
      component.stamina = 0;
    }
  }
}
