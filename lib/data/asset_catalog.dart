import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/animal.dart';
import '../models/decoration.dart';
import '../models/plant.dart';

class AssetCatalog {
  const AssetCatalog({
    required this.plants,
    required this.animals,
    required this.decorations,
  });

  final List<PlantBase> plants;
  final List<AnimalBase> animals;
  final List<DecorationBase> decorations;

  Map<String, PlantBase> get plantsById => {
    for (final item in plants) item.id: item,
  };
  Map<String, AnimalBase> get animalsById => {
    for (final item in animals) item.id: item,
  };
  Map<String, DecorationBase> get decorationsById => {
    for (final item in decorations) item.id: item,
  };
}

/// Loads the bundled catalog and converts its entries to typed base models.
class AssetCatalogLoader {
  const AssetCatalogLoader({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;

  Future<AssetCatalog> load({
    String assetPath = 'assets/config/initial_database.json',
  }) async {
    final source = await (_bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Catalog root must be a JSON object: $assetPath');
    }

    return AssetCatalog(
      plants: _readList(decoded, 'plants', _plantFromJson),
      animals: _readList(decoded, 'animals', _animalFromJson),
      decorations: _readList(decoded, 'decorations', _decorationFromJson),
    );
  }

  static List<T> _readList<T>(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic>) convert,
  ) {
    final value = json[key];
    if (value is! List) throw FormatException('Catalog "$key" must be a list.');
    return List.unmodifiable(
      value.map((item) {
        if (item is! Map<String, dynamic>) {
          throw FormatException('Every entry in "$key" must be an object.');
        }
        return convert(item);
      }),
    );
  }

  static PlantBase _plantFromJson(Map<String, dynamic> json) => PlantBase(
    id: _string(json, 'id'),
    name: _string(json, 'nazwa'),
    reqLight: _number(json, 'wymaganiaSwietlne'),
    reqCO2: _number(json, 'wymaganiaCO2'),
    growthRate: _number(json, 'tempoWzrostu'),
    splitChance: _number(json, 'szansaNaPodzial'),
  );

  static AnimalBase _animalFromJson(Map<String, dynamic> json) => AnimalBase(
    id: _string(json, 'id'),
    name: _string(json, 'nazwa'),
    bioLoad: _number(json, 'obciazenieBiologiczne'),
    reqSpace: _number(json, 'wymaganeMiejsce'),
    breedAge: _number(json, 'wiekRozmnazania'),
    breedChance: _number(json, 'szansaNaRozrod'),
  );

  static DecorationBase _decorationFromJson(Map<String, dynamic> json) {
    final dimensions = _object(json, 'wymiarySiatki');
    final waterImpact = _object(json, 'wplywNaWode');
    return DecorationBase(
      id: _string(json, 'id'),
      name: _string(json, 'nazwa'),
      category: _string(json, 'kategoria'),
      gridWidth: _integer(dimensions, 'x'),
      gridDepth: _integer(dimensions, 'y'),
      phModifier: _number(waterImpact, 'phModifier'),
      hardnessModifier: _number(waterImpact, 'hardnessModifier'),
      purchasePrice: _integer(json, 'cenaZakupu'),
    );
  }

  static Map<String, dynamic> _object(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Catalog field "$key" must be an object.');
  }

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw FormatException('Catalog field "$key" must be a string.');
  }

  static double _number(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    throw FormatException('Catalog field "$key" must be a number.');
  }

  static int _integer(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toInt();
    throw FormatException('Catalog field "$key" must be a number.');
  }
}
