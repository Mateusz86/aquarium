import 'aquarium.dart';

class PlayerProfile {
  PlayerProfile({
    required this.name,
    this.softCurrency = 0,
    this.hardCurrency = 0,
    List<Aquarium>? aquariums,
  }) : aquariums = aquariums ?? <Aquarium>[];

  String name;
  int softCurrency;
  int hardCurrency;
  final List<Aquarium> aquariums;
}
