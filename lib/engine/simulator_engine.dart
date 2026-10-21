import 'dart:math';

import '../config/game_config.dart';
import '../models/aquarium.dart';
import '../models/animal.dart';
import '../models/equipment.dart';
import '../models/plant.dart';

/// Runs one aquarium simulation. Randomness is injectable to make the domain
/// engine reproducible in a host application or tests.
class SimulatorEngine {
  SimulatorEngine({
    required this.aquarium,
    required this.config,
    Random? random,
  }) : _random = random ?? Random();

  final Aquarium aquarium;
  final GameConfig config;
  final Random _random;
  bool _isTicking = false;

  /// Executes one state transition in strict fauna → hardware → flora →
  /// environment order. Concurrent calls are serialized by rejecting overlap.
  Future<void> tick() async {
    if (_isTicking) throw StateError('A simulation tick is already running.');
    _isTicking = true;
    try {
      _simulateFauna();
      _simulateHardware();
      _simulateFlora();
      _simulateEnvironment();
    } finally {
      _isTicking = false;
    }
  }

  void _simulateFauna() {
    final water = aquarium.waterParams;
    for (final animal in aquarium.animals) {
      animal.age += config.ageDaysPerTick;
      animal.hungerLevel = _clamp(
        animal.hungerLevel + config.baseHungerRate,
        config.minHunger,
        config.maxHunger,
      );
      if (animal.hungerLevel >= config.hungerHealthThreshold) {
        animal.health = _clamp(
          animal.health - config.hungerHealthDamage,
          0,
          config.maxHealth,
        );
      }
      water.no3 += animal.base.bioLoad * config.bioLoadNo3Multiplier;
      water.po4 += animal.base.bioLoad * config.bioLoadPo4Multiplier;
    }
  }

  void _simulateHardware() {
    final water = aquarium.waterParams;
    for (final filter in aquarium.filters.where((item) => item.isActive)) {
      water.no3 = max(
        0.0,
        water.no3 - filter.base.capacity * config.filterNo3ReductionPerCapacity,
      );
    }
    for (final addon in aquarium.addons.where((item) => item.isActive)) {
      switch (addon.base.modifierType) {
        case ModifierType.co2:
          water.co2 += addon.modifierValue;
        case ModifierType.no3:
          water.no3 = max(0.0, water.no3 + addon.modifierValue);
        case ModifierType.po4:
          water.po4 = max(0.0, water.po4 + addon.modifierValue);
        case ModifierType.ph:
          water.ph += addon.modifierValue;
        case ModifierType.temperature:
          water.temperature += addon.modifierValue;
        case ModifierType.light:
          water.light += addon.modifierValue;
      }
    }
  }

  void _simulateFlora() {
    final water = aquarium.waterParams;
    for (final plant in aquarium.plants) {
      final base = plant.base;
      final requirementsMet =
          water.light >= base.reqLight &&
          water.co2 >= base.reqCO2 &&
          water.no3 >= base.reqNO3 &&
          water.po4 >= base.reqPO4 &&
          water.ph >= base.minPH &&
          water.ph <= base.maxPH &&
          water.temperature >= base.minTemperature &&
          water.temperature <= base.maxTemperature &&
          plant.health >= config.plantGrowthHealthThreshold;
      if (requirementsMet) {
        final growth = min(
          base.growthRate,
          config.plantMaximumSize - plant.size,
        );
        if (growth > 0) {
          plant.size = _clamp(
            plant.size + growth,
            config.plantMinimumSize,
            config.plantMaximumSize,
          );
          water.no3 = max(
            0.0,
            water.no3 - growth * config.plantNo3ConsumptionPerGrowth,
          );
          water.po4 = max(
            0.0,
            water.po4 - growth * config.plantPo4ConsumptionPerGrowth,
          );
        }
      } else {
        plant.health = _clamp(
          plant.health - config.plantHealthDamagePerTick,
          0,
          config.maxHealth,
        );
      }
    }
  }

  void _simulateEnvironment() {
    for (final plant in aquarium.plants) {
      if (aquarium.waterParams.no3 > config.algaeThresholdNO3) {
        plant.algaeLevel = _clamp(
          plant.algaeLevel + config.algaeGrowthPerTick,
          0,
          config.maxAlgaeLevel,
        );
      }
    }

    _evaluatePlantSplits();
    _evaluateAnimalBreeding();
  }

  void _evaluatePlantSplits() {
    // Snapshot prevents newly created offspring from splitting again in this tick.
    final originals = List<PlantInstance>.of(aquarium.plants);
    for (final plant in originals) {
      if (plant.health < config.splitHealthThreshold ||
          plant.size < config.plantMaximumSize) {
        continue;
      }
      if (_roll(plant.base.splitChance)) {
        final offspringSize =
            plant.size * _clamp(config.splitSizeFraction, 0, 1);
        plant.size = offspringSize;
        final offspring = plant.duplicate(
          x: _clamp(
            plant.posX + config.splitOffsetX,
            0,
            aquarium.gridWidth.toDouble(),
          ),
          y: _clamp(
            plant.posY + config.splitOffsetY,
            0,
            aquarium.gridDepth.toDouble(),
          ),
        );
        offspring.size = offspringSize;
        if (offspring.resalePrice == 0) {
          offspring.resalePrice = config.defaultResalePrice;
        }
        aquarium.plants.add(offspring);
      }
    }
  }

  void _evaluateAnimalBreeding() {
    final originals = List<AnimalInstance>.of(aquarium.animals);
    final eligible = originals
        .where(
          (animal) =>
              animal.health >= config.breedHealthThreshold &&
              animal.age >= animal.base.breedAge,
        )
        .toList();
    final bred = <AnimalBase>{};
    for (final parent in eligible) {
      if (bred.contains(parent.base) ||
          !eligible.any(
            (other) =>
                !identical(other, parent) && other.base.id == parent.base.id,
          )) {
        continue;
      }
      if (_roll(parent.base.breedChance)) {
        aquarium.animals.add(parent.offspring());
        bred.add(parent.base);
      }
    }
  }

  bool _roll(double chance) => _random.nextDouble() < _clamp(chance, 0, 1);

  /// Applies elapsed wall time in bounded chunks and yields between chunks so
  /// the caller's event loop can continue processing UI/platform work.
  Future<void> fastForward(DateTime lastSavedTime) async {
    final elapsed = DateTime.now().difference(lastSavedTime);
    if (elapsed.isNegative) return;
    final maximumDuration = Duration(days: config.offlineCatchupMaxDays);
    final boundedElapsed = elapsed > maximumDuration
        ? maximumDuration
        : elapsed;
    final ticks = boundedElapsed.inMilliseconds ~/ config.tickIntervalMs;
    const ticksPerChunk = 120;
    for (var completed = 0; completed < ticks; completed++) {
      await tick();
      if ((completed + 1) % ticksPerChunk == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }
  }

  double _clamp(double value, double lower, double upper) =>
      value < lower ? lower : (value > upper ? upper : value);
}
