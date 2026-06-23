import '../app/constants.dart';

class GameItem {
  String id;
  String name;
  String description;
  Quality quality;
  ItemType type;
  int quantity;
  Map<String, int> attributes;
  String? specialEffect;
  String? boundGeneralId;

  GameItem({
    required this.id,
    required this.name,
    this.description = '',
    this.quality = Quality.white,
    this.type = ItemType.consumable,
    this.quantity = 1,
    Map<String, int>? attributes,
    this.specialEffect,
    this.boundGeneralId,
  }) : attributes = attributes ?? {};

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'quality': quality.name,
    'type': type.name,
    'quantity': quantity,
    'attributes': Map<String, int>.from(attributes),
    'specialEffect': specialEffect,
    'boundGeneralId': boundGeneralId,
  };

  factory GameItem.fromJson(Map<String, dynamic> json) => GameItem(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    quality: Quality.values.firstWhere(
      (e) => e.name == json['quality'],
      orElse: () => Quality.white,
    ),
    type: ItemType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => ItemType.consumable,
    ),
    quantity: json['quantity'] as int? ?? 1,
    attributes:
        (json['attributes'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ??
        {},
    specialEffect: json['specialEffect'] as String?,
    boundGeneralId: json['boundGeneralId'] as String?,
  );
}
