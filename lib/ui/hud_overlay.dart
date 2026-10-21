import 'package:flutter/material.dart';

import '../game/aquarium_game.dart';
import '../models/inventory.dart';
import '../models/player_profile.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({
    required this.game,
    required this.playerProfile,
    required this.inventory,
    super.key,
  });

  final AquariumGame game;
  final PlayerProfile playerProfile;
  final Inventory inventory;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.hudRevision,
      builder: (context, revision, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _TopBar(playerProfile: playerProfile),
                const Spacer(),
                _ActionPanel(
                  onFeed: game.feedAnimals,
                  onChangeWater: () => game.changeWater(30),
                  onInventory: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => InventorySheet(inventory: inventory),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.playerProfile});

  final PlayerProfile playerProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _CurrencyChip(
          icon: Icons.monetization_on,
          amount: playerProfile.softCurrency,
        ),
        const SizedBox(width: 8),
        _CurrencyChip(icon: Icons.diamond, amount: playerProfile.hardCurrency),
      ],
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({required this.icon, required this.amount});

  final IconData icon;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.65),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.amberAccent, size: 20),
            const SizedBox(width: 6),
            Text(
              '$amount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.onFeed,
    required this.onChangeWater,
    required this.onInventory,
  });

  final VoidCallback onFeed;
  final VoidCallback onChangeWater;
  final VoidCallback onInventory;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.68),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onFeed,
              icon: const Icon(Icons.set_meal),
              label: const Text('Nakarm'),
            ),
            FilledButton.icon(
              onPressed: onChangeWater,
              icon: const Icon(Icons.water_drop),
              label: const Text('Podmień wodę'),
            ),
            OutlinedButton.icon(
              onPressed: onInventory,
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Ekwipunek'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class InventorySheet extends StatelessWidget {
  const InventorySheet({required this.inventory, super.key});

  final Inventory inventory;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Ekwipunek', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _InventorySection(
              title: 'Rośliny',
              names: inventory.plants.map((item) => item.base.name).toList(),
            ),
            _InventorySection(
              title: 'Zwierzęta',
              names: inventory.animals.map((item) => item.base.name).toList(),
            ),
            _InventorySection(
              title: 'Wyposażenie',
              names: inventory.equipment.map((item) => item.base.name).toList(),
            ),
            _InventorySection(
              title: 'Dodatki',
              names: inventory.addons.map((item) => item.base.name).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventorySection extends StatelessWidget {
  const _InventorySection({required this.title, required this.names});

  final String title;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (names.isEmpty)
          const ListTile(title: Text('Brak przedmiotów'))
        else
          ...names.map(
            (name) => ListTile(
              dense: true,
              leading: const Icon(Icons.circle, size: 10),
              title: Text(name),
            ),
          ),
      ],
    );
  }
}
