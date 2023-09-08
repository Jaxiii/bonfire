import 'package:bonfire/bonfire.dart';
import 'package:example/tiled_map/random_map_game.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../maps/map_biome_2.dart';
import '../network/message.dart';
import '../network/message_service.dart';
import '../utils/enums/map_id_enum.dart';
import '../utils/enums/show_in_enum.dart';
import 'game_tiled_map.dart';

// For sake of simplicity, we are using global variables here
// But avoid using global variables in your production code, this is not
// considered a good practice in most cases.
MapBiomeId currentMapBiomeId = MapBiomeId.none;
late Function(MapBiomeId) selectMap;

class MultiScenario2 extends StatefulWidget {
  const MultiScenario2({Key? key}) : super(key: key);

  @override
  State<MultiScenario2> createState() => _MultiScenarioState();
}

class _MultiScenarioState extends State<MultiScenario2> {
  @override
  void dispose() {
    currentMapBiomeId = MapBiomeId.none;
    messageService.dispose();
    super.dispose();
  }

  late final GameController gameController;
  late final MessageService messageService;
  late final String player_id;
  @override
  void initState() {
    player_id = const Uuid().v1();
    gameController = BonfireInjector.instance.get<GameController>();
    messageService = BonfireInjector.instance.get<MessageService>();
    messageService.init();
    super.initState();
    selectMap = (MapBiomeId id) {
      setState(() {
        if (id == MapBiomeId.none) {
          currentMapBiomeId = MapBiomeId.biome1;
        } else {
          currentMapBiomeId = id;
        }
      });
    };
    super.initState();
  }

  Widget _renderWidget(String? id) {
    switch (currentMapBiomeId) {
      case MapBiomeId.biome1:
        return GameTiledMap(
          showInEnum: ShowInEnum.right,
          id: id!,
          messageService: messageService,
        );
      case MapBiomeId.biome2:
        return RandomMapGame(
          size: Vector2(150, 150),
          seed: 1936,
          id: id!,
          messageService: messageService,
        );
      default:
        return GameTiledMap(
          showInEnum: ShowInEnum.right,
          id: id!,
          messageService: messageService,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _renderWidget(player_id),
    );
  }
}
