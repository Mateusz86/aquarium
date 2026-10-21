/// Simulation balancing values. Rates are applied once per tick unless their
/// names specify another unit.
class GameConfig {
  const GameConfig({
    this.tickIntervalMs = 60000,
    this.offlineCatchupMaxDays = 7,
    this.baseHungerRate = 0.002,
    this.hungerHealthThreshold = 0.75,
    this.hungerHealthDamage = 0.5,
    this.bioLoadNo3Multiplier = 1,
    this.bioLoadPo4Multiplier = 0.1,
    this.filterNo3ReductionPerCapacity = 0.001,
    this.algaeThresholdNO3 = 40,
    this.algaeGrowthPerTick = 1,
    this.plantNo3ConsumptionPerGrowth = 0.1,
    this.plantPo4ConsumptionPerGrowth = 0.01,
    this.plantHealthDamagePerTick = 1,
    this.plantGrowthHealthThreshold = 1,
    this.plantMaximumSize = 1,
    this.plantMinimumSize = 0.1,
    this.maxHealth = 100,
    this.maxHunger = 1,
    this.minHunger = 0,
    this.maxAlgaeLevel = 100,
    this.breedHealthThreshold = 75,
    this.splitHealthThreshold = 75,
    this.breedAgeDaysPerTick = 1 / 1440,
    this.ageDaysPerTick = 1 / 1440,
    this.defaultResalePrice = 0,
    this.splitOffsetX = 0.5,
    this.splitOffsetY = 0.5,
    this.splitSizeFraction = 0.5,
  }) : assert(tickIntervalMs > 0),
       assert(offlineCatchupMaxDays >= 0);

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    final defaults = const GameConfig();
    int intValue(String key, int fallback) =>
        (json[key] as num?)?.toInt() ?? fallback;
    double doubleValue(String key, double fallback) =>
        (json[key] as num?)?.toDouble() ?? fallback;

    return GameConfig(
      tickIntervalMs: intValue('tickIntervalMs', defaults.tickIntervalMs),
      offlineCatchupMaxDays: intValue(
        'offlineCatchupMaxDays',
        defaults.offlineCatchupMaxDays,
      ),
      baseHungerRate: doubleValue('baseHungerRate', defaults.baseHungerRate),
      hungerHealthThreshold: doubleValue(
        'hungerHealthThreshold',
        defaults.hungerHealthThreshold,
      ),
      hungerHealthDamage: doubleValue(
        'hungerHealthDamage',
        defaults.hungerHealthDamage,
      ),
      bioLoadNo3Multiplier: doubleValue(
        'bioLoadNo3Multiplier',
        defaults.bioLoadNo3Multiplier,
      ),
      bioLoadPo4Multiplier: doubleValue(
        'bioLoadPo4Multiplier',
        defaults.bioLoadPo4Multiplier,
      ),
      filterNo3ReductionPerCapacity: doubleValue(
        'filterNo3ReductionPerCapacity',
        defaults.filterNo3ReductionPerCapacity,
      ),
      algaeThresholdNO3: doubleValue(
        'algaeThresholdNO3',
        defaults.algaeThresholdNO3,
      ),
      algaeGrowthPerTick: doubleValue(
        'algaeGrowthPerTick',
        defaults.algaeGrowthPerTick,
      ),
      plantNo3ConsumptionPerGrowth: doubleValue(
        'plantNo3ConsumptionPerGrowth',
        defaults.plantNo3ConsumptionPerGrowth,
      ),
      plantPo4ConsumptionPerGrowth: doubleValue(
        'plantPo4ConsumptionPerGrowth',
        defaults.plantPo4ConsumptionPerGrowth,
      ),
      plantHealthDamagePerTick: doubleValue(
        'plantHealthDamagePerTick',
        defaults.plantHealthDamagePerTick,
      ),
      plantGrowthHealthThreshold: doubleValue(
        'plantGrowthHealthThreshold',
        defaults.plantGrowthHealthThreshold,
      ),
      plantMaximumSize: doubleValue(
        'plantMaximumSize',
        defaults.plantMaximumSize,
      ),
      plantMinimumSize: doubleValue(
        'plantMinimumSize',
        defaults.plantMinimumSize,
      ),
      maxHealth: doubleValue('maxHealth', defaults.maxHealth),
      maxHunger: doubleValue('maxHunger', defaults.maxHunger),
      minHunger: doubleValue('minHunger', defaults.minHunger),
      maxAlgaeLevel: doubleValue('maxAlgaeLevel', defaults.maxAlgaeLevel),
      breedHealthThreshold: doubleValue(
        'breedHealthThreshold',
        defaults.breedHealthThreshold,
      ),
      splitHealthThreshold: doubleValue(
        'splitHealthThreshold',
        defaults.splitHealthThreshold,
      ),
      breedAgeDaysPerTick: doubleValue(
        'breedAgeDaysPerTick',
        defaults.breedAgeDaysPerTick,
      ),
      ageDaysPerTick: doubleValue('ageDaysPerTick', defaults.ageDaysPerTick),
      defaultResalePrice: intValue(
        'defaultResalePrice',
        defaults.defaultResalePrice,
      ),
      splitOffsetX: doubleValue('splitOffsetX', defaults.splitOffsetX),
      splitOffsetY: doubleValue('splitOffsetY', defaults.splitOffsetY),
      splitSizeFraction: doubleValue(
        'splitSizeFraction',
        defaults.splitSizeFraction,
      ),
    );
  }

  final int tickIntervalMs;
  final int offlineCatchupMaxDays;
  final double baseHungerRate;
  final double hungerHealthThreshold;
  final double hungerHealthDamage;
  final double bioLoadNo3Multiplier;
  final double bioLoadPo4Multiplier;
  final double filterNo3ReductionPerCapacity;
  final double algaeThresholdNO3;
  final double algaeGrowthPerTick;
  final double plantNo3ConsumptionPerGrowth;
  final double plantPo4ConsumptionPerGrowth;
  final double plantHealthDamagePerTick;
  final double plantGrowthHealthThreshold;
  final double plantMaximumSize;
  final double plantMinimumSize;
  final double maxHealth;
  final double maxHunger;
  final double minHunger;
  final double maxAlgaeLevel;
  final double breedHealthThreshold;
  final double splitHealthThreshold;
  final double breedAgeDaysPerTick;
  final double ageDaysPerTick;
  final int defaultResalePrice;
  final double splitOffsetX;
  final double splitOffsetY;
  final double splitSizeFraction;
}
