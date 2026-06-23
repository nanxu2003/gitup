import 'player.dart';
import 'building.dart';
import 'general.dart';
import 'item.dart';
import 'quest.dart';
import 'formation.dart';
import 'chapter.dart';

class GameSave {
  Player player;
  List<Building> buildings;
  List<General> generals;
  List<GameItem> inventory;
  List<Quest> quests;
  List<Formation> formations;
  List<Chapter> chapters;
  Map<String, bool> storyFlags;
  Map<String, int> mapProgress;
  List<String> completedEventIds;
  String savedAt;
  int slotIndex;

  GameSave({
    required this.player,
    List<Building>? buildings,
    List<General>? generals,
    List<GameItem>? inventory,
    List<Quest>? quests,
    List<Formation>? formations,
    List<Chapter>? chapters,
    Map<String, bool>? storyFlags,
    Map<String, int>? mapProgress,
    List<String>? completedEventIds,
    String? savedAt,
    this.slotIndex = 0,
  }) : buildings = buildings ?? [],
       generals = generals ?? [],
       inventory = inventory ?? [],
       quests = quests ?? [],
       formations = formations ?? [],
       chapters = chapters ?? [],
       storyFlags = storyFlags ?? {},
       mapProgress = mapProgress ?? {},
       completedEventIds = completedEventIds ?? [],
       savedAt = savedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toJson() => {
    'player': player.toJson(),
    'buildings': buildings.map((b) => b.toJson()).toList(),
    'generals': generals.map((g) => g.toJson()).toList(),
    'inventory': inventory.map((i) => i.toJson()).toList(),
    'quests': quests.map((q) => q.toJson()).toList(),
    'formations': formations.map((f) => f.toJson()).toList(),
    'chapters': chapters.map((c) => c.toJson()).toList(),
    'storyFlags': Map<String, bool>.from(storyFlags),
    'mapProgress': Map<String, int>.from(mapProgress),
    'completedEventIds': List<String>.from(completedEventIds),
    'savedAt': savedAt,
    'slotIndex': slotIndex,
  };

  factory GameSave.fromJson(Map<String, dynamic> json) => GameSave(
    player: Player.fromJson(json['player'] as Map<String, dynamic>),
    buildings:
        (json['buildings'] as List<dynamic>?)
            ?.map((e) => Building.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    generals:
        (json['generals'] as List<dynamic>?)
            ?.map((e) => General.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    inventory:
        (json['inventory'] as List<dynamic>?)
            ?.map((e) => GameItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    quests:
        (json['quests'] as List<dynamic>?)
            ?.map((e) => Quest.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    formations:
        (json['formations'] as List<dynamic>?)
            ?.map((e) => Formation.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    chapters:
        (json['chapters'] as List<dynamic>?)
            ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    storyFlags:
        (json['storyFlags'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as bool),
        ) ??
        {},
    mapProgress:
        (json['mapProgress'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ??
        {},
    completedEventIds:
        (json['completedEventIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    savedAt: json['savedAt'] as String?,
    slotIndex: json['slotIndex'] as int? ?? 0,
  );
}
