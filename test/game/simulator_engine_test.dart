import 'package:aquarium/config/game_config.dart';
import 'package:aquarium/engine/simulator_engine.dart';
import 'package:aquarium/models/animal.dart';
import 'package:aquarium/models/aquarium.dart';
import 'package:aquarium/models/equipment.dart';
import 'package:aquarium/models/plant.dart';
import 'package:test/test.dart';

void main() {
  late GameConfig config;
  late WaterParameters water;
  late Aquarium aquarium;
  late AnimalInstance fish;
  late PlantInstance plant;
  late SimulatorEngine engine;

  setUp(() {
    config = const GameConfig(
      tickIntervalMs: 60 * 1000,
      offlineCatchupMaxDays: 7,
      baseHungerRate: 0.001,
      hungerHealthThreshold: 0.8,
      hungerHealthDamage: 2,
      bioLoadNo3Multiplier: 1,
      bioLoadPo4Multiplier: 0.1,
      filterNo3ReductionPerCapacity: 0.01,
      algaeThresholdNO3: 1000,
      plantNo3ConsumptionPerGrowth: 0.5,
      plantPo4ConsumptionPerGrowth: 0.1,
      plantHealthDamagePerTick: 5,
      plantGrowthHealthThreshold: 1,
      plantMaximumSize: 1,
      plantMinimumSize: 0.1,
      ageDaysPerTick: 0,
      splitSizeFraction: 0.5,
    );
    water = WaterParameters(
      co2: 20,
      no3: 20,
      po4: 10,
      ph: 7,
      temperature: 25,
      light: 20,
    );
    fish = AnimalInstance(
      base: const AnimalBase(
        id: 'test-fish',
        name: 'Test Fish',
        bioLoad: 2,
        reqSpace: 10,
        breedAge: 1000,
        breedChance: 0,
      ),
    );
    plant = PlantInstance(
      base: const PlantBase(
        id: 'test-plant',
        name: 'Test Plant',
        reqLight: 10,
        reqCO2: 10,
        reqNO3: 1,
        reqPO4: 1,
        growthRate: 0.1,
        splitChance: 0,
      ),
      posX: 2,
      posY: 2,
      zIndex: 0,
      size: 0.4,
    );
    aquarium = Aquarium(
      capacityLiters: 100,
      gridWidth: 10,
      gridDepth: 10,
      height: 10,
      waterParams: water,
      animals: [fish],
      plants: [plant],
    );
    engine = SimulatorEngine(aquarium: aquarium, config: config);
  });

  group('SimulatorEngine.tick', () {
    test('ryby zwiększają głód i obciążają wodę azotanami', () async {
      aquarium.plants.clear();
      final initialHunger = fish.hungerLevel;
      final initialNo3 = water.no3;

      for (var i = 0; i < 5; i++) {
        await engine.tick();
      }

      expect(fish.hungerLevel, greaterThan(initialHunger));
      expect(
        fish.hungerLevel,
        closeTo(initialHunger + 5 * config.baseHungerRate, 1e-10),
      );
      expect(water.no3, closeTo(initialNo3 + 5 * fish.base.bioLoad, 1e-10));
    });

    test('aktywny filtr redukuje azotany dodane przez rybę', () async {
      aquarium.plants.clear();
      final initialNo3 = water.no3;
      aquarium.filters.add(
        EquipmentInstance(
          base: const EquipmentBase(
            id: 'strong-filter',
            name: 'Strong Filter',
            capacity: 500,
          ),
        ),
      );

      await engine.tick();

      // Ryba wnosi 2 jednostki, a filtr usuwa 5 w tym samym ticku.
      expect(water.no3, lessThan(initialNo3));
      expect(water.no3, closeTo(initialNo3 - 3, 1e-10));
    });

    test(
      'roślina rośnie i zużywa azotany przy odpowiednich warunkach',
      () async {
        final initialNo3 = water.no3;
        final initialSize = plant.size;

        await engine.tick();

        expect(plant.size, greaterThan(initialSize));
        expect(water.no3, lessThan(initialNo3 + fish.base.bioLoad));
        expect(
          water.no3,
          closeTo(
            initialNo3 +
                fish.base.bioLoad -
                0.1 * config.plantNo3ConsumptionPerGrowth,
            1e-10,
          ),
        );
      },
    );

    test('niedobór CO2 i światła obniża zdrowie rośliny', () async {
      water.co2 = 0;
      water.light = 0;
      final initialHealth = plant.health;

      await engine.tick();

      expect(plant.health, lessThan(initialHealth));
      expect(
        plant.health,
        closeTo(initialHealth - config.plantHealthDamagePerTick, 1e-10),
      );
    });
  });

  test('fastForward wykonuje ticki odpowiadające dwóm godzinom', () async {
    aquarium.plants.clear();
    final initialHunger = fish.hungerLevel;
    final initialNo3 = water.no3;
    final lastSavedTime = DateTime.now().subtract(const Duration(hours: 2));

    await engine.fastForward(lastSavedTime);

    const expectedTicks = 120;
    expect(
      fish.hungerLevel,
      closeTo(initialHunger + expectedTicks * config.baseHungerRate, 1e-8),
    );
    expect(
      water.no3,
      closeTo(initialNo3 + expectedTicks * fish.base.bioLoad, 1e-8),
    );
  });
}
