import '../models/game_save.dart';
import '../app/constants.dart';
import 'storage_service.dart';

class SaveService {
  final StorageService _storage;

  SaveService(this._storage);

  String _slotKey(int slot) => 'save_slot_$slot';

  Future<void> saveGame(GameSave save, int slot) async {
    save.slotIndex = slot;
    save.savedAt = DateTime.now().toIso8601String();
    await _storage.saveJson(_slotKey(slot), save.toJson());
  }

  Future<GameSave?> loadGame(int slot) async {
    final data = _storage.getJson(_slotKey(slot));
    if (data == null) return null;
    try {
      return GameSave.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<List<int>> getSaveSlots() async {
    final slots = <int>[];
    for (int i = 0; i < maxSaveSlots; i++) {
      if (_storage.hasKey(_slotKey(i))) {
        slots.add(i);
      }
    }
    return slots;
  }

  Future<String?> getSaveInfo(int slot) async {
    final data = _storage.getJson(_slotKey(slot));
    if (data == null) return null;
    try {
      final save = GameSave.fromJson(data);
      return '${save.player.name} · Lv.${save.player.level} · 第${save.player.day}日';
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteSave(int slot) async {
    await _storage.remove(_slotKey(slot));
  }

  Future<void> autoSave(GameSave save) async {
    await saveGame(save, 0);
  }

  bool hasAnySave() {
    for (int i = 0; i < maxSaveSlots; i++) {
      if (_storage.hasKey(_slotKey(i))) return true;
    }
    return false;
  }
}
