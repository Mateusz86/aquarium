class AnimalBase {
  const AnimalBase({
    required this.id,
    required this.name,
    required this.bioLoad,
    required this.reqSpace,
    required this.breedAge,
    required this.breedChance,
  });

  final String id;
  final String name;
  final double bioLoad;
  final double reqSpace;
  final double breedAge;
  final double breedChance;
}

class AnimalInstance {
  AnimalInstance({
    required this.base,
    this.age = 0,
    this.health = 100,
    this.hungerLevel = 0,
  });

  final AnimalBase base;
  double age;
  double health;
  double hungerLevel;

  AnimalInstance offspring() => AnimalInstance(base: base);
}
