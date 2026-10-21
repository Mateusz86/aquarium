class DecorationBase {
  const DecorationBase({
    required this.id,
    required this.name,
    required this.category,
    required this.gridWidth,
    required this.gridDepth,
    required this.phModifier,
    required this.hardnessModifier,
    required this.purchasePrice,
  });

  final String id;
  final String name;
  final String category;
  final int gridWidth;
  final int gridDepth;
  final double phModifier;
  final double hardnessModifier;
  final int purchasePrice;
}
