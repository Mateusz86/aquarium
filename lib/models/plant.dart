class PlantBase {
  const PlantBase({
    required this.id,
    required this.name,
    required this.reqLight,
    required this.reqCO2,
    required this.growthRate,
    required this.splitChance,
    this.reqNO3 = 0,
    this.reqPO4 = 0,
    this.minPH = 0,
    this.maxPH = 14,
    this.minTemperature = 0,
    this.maxTemperature = 50,
  });

  final String id;
  final String name;
  final double reqLight;
  final double reqCO2;
  final double growthRate;
  final double splitChance;
  final double reqNO3;
  final double reqPO4;
  final double minPH;
  final double maxPH;
  final double minTemperature;
  final double maxTemperature;
}

class PlantInstance {
  PlantInstance({
    required this.base,
    required this.posX,
    required this.posY,
    required this.zIndex,
    this.size = 0.5,
    this.health = 100,
    this.algaeLevel = 0,
    this.resalePrice = 0,
  });

  final PlantBase base;
  double posX;
  double posY;
  int zIndex;
  double size;
  double health;
  double algaeLevel;
  int resalePrice;

  PlantInstance duplicate({required double x, required double y}) =>
      PlantInstance(
        base: base,
        posX: x,
        posY: y,
        zIndex: zIndex,
        size: size,
        health: health,
        algaeLevel: algaeLevel,
        resalePrice: resalePrice,
      );
}
