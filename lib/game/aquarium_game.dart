import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../engine/simulator_engine.dart';
import 'plant_component.dart';

class AquariumGame extends FlameGame {
  AquariumGame({
    required this.engine,
    this.gridCellSize = 64,
    this.onSimulationError,
  });

  final SimulatorEngine engine;
  final double gridCellSize;
  final void Function(Object error, StackTrace stackTrace)? onSimulationError;
  final ValueNotifier<int> _hudRevision = ValueNotifier<int>(0);

  ValueListenable<int> get hudRevision => _hudRevision;

  double _tickAccumulator = 0;
  bool _tickInProgress = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(
      SpriteComponent(
        sprite: await loadSprite('aquarium_background.jpeg'),
        position: Vector2.zero(),
        size: canvasSize,
        priority: -1000000,
      ),
    );

    for (final plant in engine.aquarium.plants) {
      final screenY = canvasSize.y - plant.posY * gridCellSize;
      final yDepthPriority = -(plant.posY * 1000).round();
      await add(
        PlantComponent(
          instance: plant,
          position: Vector2((plant.posX + 0.5) * gridCellSize, screenY),
          priority: yDepthPriority + plant.zIndex,
          cellSize: gridCellSize,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final tickSeconds = engine.config.tickIntervalMs / 1000;
    _tickAccumulator += dt;

    if (_tickAccumulator >= tickSeconds && !_tickInProgress) {
      _tickAccumulator -= tickSeconds;
      unawaited(_runTick());
    }
  }

  void feedAnimals() {
    engine.aquarium.feedAnimals();
    notifyHudChanged();
  }

  void changeWater(double percentage) {
    engine.aquarium.changeWater(percentage);
    notifyHudChanged();
  }

  void notifyHudChanged() => _hudRevision.value++;

  Future<void> _runTick() async {
    _tickInProgress = true;
    try {
      await engine.tick();
      notifyHudChanged();
    } catch (error, stackTrace) {
      if (onSimulationError case final handler?) {
        handler(error, stackTrace);
      } else {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'aquarium simulation',
          ),
        );
      }
    } finally {
      _tickInProgress = false;
    }
  }
}
