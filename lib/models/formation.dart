class Formation {
  String id;
  String name;
  String description;
  Map<String, double> bonuses;
  List<List<String?>> slots;
  int frontSlots;
  int midSlots;
  int backSlots;

  Formation({
    required this.id,
    required this.name,
    this.description = '',
    Map<String, double>? bonuses,
    List<List<String?>>? slots,
    this.frontSlots = 2,
    this.midSlots = 2,
    this.backSlots = 1,
  }) : bonuses = bonuses ?? {},
       slots =
           slots ??
           [List.filled(2, null), List.filled(2, null), List.filled(1, null)];

  List<String> get deployedGeneralIds {
    final ids = <String>[];
    for (final row in slots) {
      for (final id in row) {
        if (id != null) ids.add(id);
      }
    }
    return ids;
  }

  int get deployedCount => deployedGeneralIds.length;

  int get totalSlots => slots.fold<int>(0, (sum, row) => sum + row.length);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'bonuses': Map<String, double>.from(bonuses),
    'slots': slots.map((row) => row.toList()).toList(),
    'frontSlots': frontSlots,
    'midSlots': midSlots,
    'backSlots': backSlots,
  };

  factory Formation.fromJson(Map<String, dynamic> json) {
    final frontSlots = json['frontSlots'] as int? ?? 2;
    final midSlots = json['midSlots'] as int? ?? 2;
    final backSlots = json['backSlots'] as int? ?? 1;
    return Formation(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      bonuses:
          (json['bonuses'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      slots:
          (json['slots'] as List<dynamic>?)
              ?.map(
                (row) =>
                    (row as List<dynamic>).map((e) => e as String?).toList(),
              )
              .toList() ??
          [
            List.filled(frontSlots, null),
            List.filled(midSlots, null),
            List.filled(backSlots, null),
          ],
      frontSlots: frontSlots,
      midSlots: midSlots,
      backSlots: backSlots,
    );
  }
}
