import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import '../../shared/player/knight.dart';
import '../tiled_map/dungeon_map.dart';
import '../tiled_map/multi_scenario2.dart';
import '../utils/constants/game_consts.dart';
import '../utils/enums/map_id_enum.dart';
import '../utils/enums/show_in_enum.dart';
import '../utils/sensors/exit_map_sensor.dart';

class MapBiome2 extends StatelessWidget {
  final ShowInEnum showInEnum;

  const MapBiome2({Key? key, this.showInEnum = ShowInEnum.left})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(
        keyboardConfig: KeyboardConfig(),
        directional: JoystickDirectional(),
      ),
      player: Knight(
        Vector2((4 * DungeonMap.tileSize), (4 * DungeonMap.tileSize)),
        id: '1',
      ),
      map: WorldMapByTiled(
        MultiScenarioAssets.mapBiome2,
        forceTileSize: Vector2.all(defaultTileSize),
        objectsBuilder: {
          'sensorLeft': (p) => ExitMapSensor(
                'sensorLeft',
                p.position,
                p.size,
                _exitMap,
              ),
          'sensorRight': (p) => ExitMapSensor(
                'sensorRight',
                p.position,
                p.size,
                _exitMap,
              ),
        },
      ),
      cameraConfig: CameraConfig(moveOnlyMapArea: true),
      progress: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: Colors.black,
      ),
    );
  }

  Vector2 _getInitPosition() {
    switch (showInEnum) {
      case ShowInEnum.left:
        return Vector2(defaultTileSize * 2, defaultTileSize * 10);
      case ShowInEnum.right:
        return Vector2(defaultTileSize * 27, defaultTileSize * 12);
      case ShowInEnum.top:
        return Vector2.zero();
      case ShowInEnum.bottom:
        return Vector2.zero();
      default:
        return Vector2.zero();
    }
  }

  void _exitMap(String value) {
    if (value == 'sensorRight') {
      selectMap(MapBiomeId.biome2);
    }
  }
}
