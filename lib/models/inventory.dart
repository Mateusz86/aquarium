import 'animal.dart';
import 'equipment.dart';
import 'plant.dart';

class Inventory {
  Inventory({
    List<PlantInstance>? plants,
    List<AnimalInstance>? animals,
    List<EquipmentInstance>? equipment,
    List<AddonInstance>? addons,
  }) : plants = plants ?? <PlantInstance>[],
       animals = animals ?? <AnimalInstance>[],
       equipment = equipment ?? <EquipmentInstance>[],
       addons = addons ?? <AddonInstance>[];

  final List<PlantInstance> plants;
  final List<AnimalInstance> animals;
  final List<EquipmentInstance> equipment;
  final List<AddonInstance> addons;
}
