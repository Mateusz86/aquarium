import 'animal.dart';
import 'equipment.dart';
import 'plant.dart';

class WaterParameters {
  WaterParameters({
    this.co2 = 0,
    this.no3 = 0,
    this.po4 = 0,
    this.ph = 7,
    this.temperature = 25,
    this.light = 0,
  });

  double co2;
  double no3;
  double po4;
  double ph;
  double temperature;
  double light;
}

class Aquarium {
  Aquarium({
    required this.capacityLiters,
    required this.gridWidth,
    required this.gridDepth,
    required this.height,
    required this.waterParams,
    List<PlantInstance>? plants,
    List<AnimalInstance>? animals,
    List<EquipmentInstance>? filters,
    List<AddonInstance>? addons,
  }) : plants = plants ?? <PlantInstance>[],
       animals = animals ?? <AnimalInstance>[],
       filters = filters ?? <EquipmentInstance>[],
       addons = addons ?? <AddonInstance>[];

  final double capacityLiters;
  final int gridWidth;
  final int gridDepth;
  final double height;
  final List<PlantInstance> plants;
  final List<AnimalInstance> animals;
  final List<EquipmentInstance> filters;
  final List<AddonInstance> addons;
  final WaterParameters waterParams;

  void feedAnimals() {
    for (final animal in animals) {
      animal.hungerLevel = 0;
    }
  }

  /// Replaces [percentage] of the aquarium water with [replacement] water.
  void changeWater(double percentage, {WaterParameters? replacement}) {
    if (!percentage.isFinite || percentage < 0 || percentage > 100) {
      throw ArgumentError.value(
        percentage,
        'percentage',
        'Must be between 0 and 100.',
      );
    }

    final fraction = percentage / 100;
    final oldFraction = 1 - fraction;
    final freshWater = replacement ?? WaterParameters();
    waterParams.co2 = waterParams.co2 * oldFraction + freshWater.co2 * fraction;
    waterParams.no3 = waterParams.no3 * oldFraction + freshWater.no3 * fraction;
    waterParams.po4 = waterParams.po4 * oldFraction + freshWater.po4 * fraction;
    waterParams.ph = waterParams.ph * oldFraction + freshWater.ph * fraction;
    waterParams.temperature =
        waterParams.temperature * oldFraction +
        freshWater.temperature * fraction;
  }
}
