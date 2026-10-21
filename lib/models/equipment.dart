enum ModifierType { co2, no3, po4, ph, temperature, light }

class EquipmentBase {
  const EquipmentBase({
    required this.id,
    required this.name,
    required this.capacity,
  });

  final String id;
  final String name;
  final double capacity;
}

class AddonBase {
  const AddonBase({
    required this.id,
    required this.name,
    required this.modifierType,
  });

  final String id;
  final String name;
  final ModifierType modifierType;
}

class EquipmentInstance {
  EquipmentInstance({required this.base, this.isActive = true});

  final EquipmentBase base;
  bool isActive;
}

class AddonInstance {
  AddonInstance({
    required this.base,
    required this.modifierValue,
    this.isActive = true,
  });

  final AddonBase base;
  final double modifierValue;
  bool isActive;
}
