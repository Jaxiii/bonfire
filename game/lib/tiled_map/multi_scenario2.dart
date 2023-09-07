import 'package:flutter/material.dart';
import '../maps/map_biome_2.dart';
import '../utils/enums/map_id_enum.dart';
import '../utils/enums/show_in_enum.dart';
import 'game_tiled_map.dart';
import 'game_tiled_map2.dart';

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
    super.dispose();
  }

  @override
  void initState() {
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

  Widget _renderWidget() {
    print('render');

    switch (currentMapBiomeId) {
      case MapBiomeId.biome1:
        return const GameTiledMap2(showInEnum: ShowInEnum.right);
      case MapBiomeId.biome2:
        return const GameTiledMap(showInEnum: ShowInEnum.right);
      default:
        return const GameTiledMap2(showInEnum: ShowInEnum.right);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _renderWidget(),
    );
  }
}
