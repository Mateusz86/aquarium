import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/game_config.dart';
import 'data/asset_catalog.dart';
import 'engine/simulator_engine.dart';
import 'game/aquarium_game.dart';
import 'models/animal.dart';
import 'models/aquarium.dart';
import 'models/inventory.dart';
import 'models/player_profile.dart';
import 'models/plant.dart';
import 'ui/hud_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final startupData = await Future.wait([
    rootBundle.loadString('assets/config/game_config.json'),
    const AssetCatalogLoader().load(),
  ]);
  final config = GameConfig.fromJson(
    (jsonDecode(startupData[0] as String) as Map).cast<String, dynamic>(),
  );
  final catalog = startupData[1] as AssetCatalog;

  final aquarium = Aquarium(
    capacityLiters: 120,
    gridWidth: 10,
    gridDepth: 10,
    height: 50,
    waterParams: WaterParameters(
      co2: 20,
      no3: 20,
      po4: 5,
      ph: 7,
      temperature: 25,
      light: 20,
    ),
    plants: [
      PlantInstance(
        base: catalog.plantsById['echinodorus_amazonicus']!,
        posX: 5,
        posY: 1,
        zIndex: 0,
        size: 0.5,
      ),
    ],
    animals: [
      AnimalInstance(base: catalog.animalsById['paracheirodon_innesi']!),
    ],
  );
  final engine = SimulatorEngine(aquarium: aquarium, config: config);
  final game = AquariumGame(engine: engine);
  final player = PlayerProfile(
    name: 'Aquarist',
    softCurrency: 250,
    hardCurrency: 10,
    aquariums: [aquarium],
  );
  final inventory = Inventory();

  runApp(AquariumApp(game: game, playerProfile: player, inventory: inventory));
}

class AquariumApp extends StatelessWidget {
  const AquariumApp({
    required this.game,
    required this.playerProfile,
    required this.inventory,
    super.key,
  });

  static const _hudOverlay = 'HudOverlay';

  final AquariumGame game;
  final PlayerProfile playerProfile;
  final Inventory inventory;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aquarium Simulator',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: Scaffold(
        body: GameWidget<AquariumGame>(
          game: game,
          initialActiveOverlays: const [_hudOverlay],
          overlayBuilderMap: {
            _hudOverlay: (context, game) => HudOverlay(
              game: game,
              playerProfile: playerProfile,
              inventory: inventory,
            ),
          },
        ),
      ),
    );
  }
}
