import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../models/plant.dart';

enum PlantGrowthStage { seedling, growing, mature }

class PlantComponent extends SpriteGroupComponent<PlantGrowthStage>
    with HasGameReference<FlameGame<World>> {
  PlantComponent({
    required this.instance,
    required super.position,
    required super.priority,
    this.cellSize = 64,
  }) : super(anchor: Anchor.bottomCenter);

  final PlantInstance instance;
  final double cellSize;
  PlantGrowthStage? _displayedStage;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final prefix = instance.base.id;
    sprites = {
      PlantGrowthStage.seedling: await game.loadSprite('${prefix}_small.png'),
      PlantGrowthStage.growing: await game.loadSprite('${prefix}_medium.png'),
      PlantGrowthStage.mature: await game.loadSprite('${prefix}_large.png'),
    };
    _syncGrowthStage();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _syncGrowthStage();
  }

  void _syncGrowthStage() {
    final stage = switch (instance.size) {
      < 0.33 => PlantGrowthStage.seedling,
      < 0.66 => PlantGrowthStage.growing,
      _ => PlantGrowthStage.mature,
    };
    if (_displayedStage != stage) {
      current = stage;
      _displayedStage = stage;
    }
    final spriteSize = sprites![stage]!.srcSize;
    final height = cellSize * instance.size;
    size = Vector2(height * spriteSize.x / spriteSize.y, height);
  }
}
