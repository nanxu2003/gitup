# Modular Game Art Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the four full-screen screenshot assets with newly generated modular backgrounds, character art, item art, and Flutter-rendered UI while preserving all existing game behavior.

**Architecture:** Runtime pages use separate background, character, and item image assets composed by responsive Flutter `Stack` layouts. All labels, panels, borders, buttons, map nodes, health bars, rewards, and dynamic values remain code-native and connected to the existing save, battle, and recruitment services.

**Tech Stack:** Flutter/Dart, CustomPainter, bundled PNG/WebP assets, built-in image generation, existing setState and shared_preferences architecture.

---

### Task 1: Establish isolated implementation workspace and asset contract

**Files:**
- Create: `lib/app/game_art.dart`
- Modify: `test/widgets/ornate_game_frame_test.dart`

**Steps:**

1. Create a feature worktree from `main`.
2. Add failing tests that require modular asset paths and reject filenames ending in `_reference.png`.
3. Add `GameArt` constants for four backgrounds, six character illustrations, and one reward item atlas.
4. Run the focused test and expect it to pass.
5. Commit with `test: define modular game art contract`.

### Task 2: Generate four clean scene backgrounds

**Files:**
- Create: `assets/images/backgrounds/world_map_bg.png`
- Create: `assets/images/backgrounds/battlefield_bg.png`
- Create: `assets/images/backgrounds/login_reward_bg.png`
- Create: `assets/images/backgrounds/recruit_hall_bg.png`

**Steps:**

1. Use each supplied screenshot as a composition reference.
2. Generate a clean environment-only image with no characters, cards, buttons, icons, borders, logos, numbers, or text.
3. Inspect each output for visible UI remnants or malformed writing.
4. Save the accepted files in the project and verify Flutter can decode them.
5. Commit with `feat: add modular scene backgrounds`.

### Task 3: Generate independent character illustrations

**Files:**
- Create: `assets/images/characters/map_guide.png`
- Create: `assets/images/characters/battle_hero_left.png`
- Create: `assets/images/characters/battle_hero_right.png`
- Create: `assets/images/characters/login_lvbu.png`
- Create: `assets/images/characters/recruit_fan_lady.png`
- Create: `assets/images/characters/recruit_dark_warrior.png`

**Steps:**

1. Generate each character from its corresponding screenshot reference while preserving identity, armor silhouette, weapon, hair, and key colors.
2. Use a flat chroma-key backdrop and remove it locally to produce transparent PNG output.
3. Validate alpha corners, subject coverage, and edge quality.
4. Commit with `feat: add modular character illustrations`.

### Task 4: Generate game item artwork

**Files:**
- Create: `assets/images/items/reward_items.png`
- Create: `lib/widgets/game_item_icon.dart`
- Create: `test/widgets/game_item_icon_test.dart`

**Steps:**

1. Generate a consistent icon sheet containing recruit order, ingot, jade, armor, scroll, crystal, chest, and coin.
2. Write a failing widget test for icon selection and rarity framing.
3. Implement a clipped sprite/atlas widget with a code-rendered rarity border.
4. Run the focused test and expect it to pass.
5. Commit with `feat: add modular reward item artwork`.

### Task 5: Compose the world map and battle pages from layers

**Files:**
- Modify: `lib/screens/world_map_screen.dart`
- Modify: `lib/screens/battle_screen.dart`
- Modify: `test/screens/world_map_screen_test.dart`
- Modify: `test/screens/battle_screen_test.dart`

**Steps:**

1. Extend tests to require background and character asset layers without reference screenshot assets.
2. Replace full-screen screenshot references with `GameArt` backgrounds.
3. Add independent character layers with responsive clipping and gradient fades.
4. Keep map nodes, stage sheets, combat formations, health bars, logs, and controls code-native.
5. Run both screen tests and expect them to pass.
6. Commit with `feat: compose modular map and battle art`.

### Task 6: Compose login rewards and recruitment from layers

**Files:**
- Modify: `lib/widgets/login_reward_overlay.dart`
- Modify: `lib/screens/recruit_screen.dart`
- Modify: `test/widgets/login_reward_overlay_test.dart`
- Modify: `test/screens/recruit_screen_test.dart`

**Steps:**

1. Extend tests to require separate background, character, and item layers.
2. Use the new login and recruitment backgrounds.
3. Place the Lü Bu, fan lady, and dark warrior art independently from panels.
4. Use `GameItemIcon` for login rewards and keep all text/code panels dynamic.
5. Ensure login reward copy contains no recharge or payment language.
6. Run both screen tests and expect them to pass.
7. Commit with `feat: compose modular reward and recruit art`.

### Task 7: Remove screenshot assets and enforce the boundary

**Files:**
- Delete: `assets/images/world_map_reference.png`
- Delete: `assets/images/battle_reference.png`
- Delete: `assets/images/login_reward_reference.png`
- Delete: `assets/images/recruit_reference.png`
- Modify: `pubspec.yaml`
- Create: `test/app/game_art_contract_test.dart`

**Steps:**

1. Add a test that scans production Dart and asset manifests for `_reference.png` usage.
2. Verify the test fails before deletion.
3. Delete all four screenshot assets and remove all references.
4. Register only the modular asset directories.
5. Run the contract test and expect it to pass.
6. Commit with `chore: remove full-screen screenshot assets`.

### Task 8: Final verification and visual comparison

**Files:**
- Modify only files implicated by verification failures.

**Steps:**

1. Run `dart format` on changed Dart files.
2. Run `flutter test` and expect all tests to pass.
3. Run `flutter analyze`; confirm no new diagnostics.
4. Build the iOS simulator app.
5. Capture the four pages at phone resolution and verify: no full-screen reference images, no text baked into generated assets, modular character layering, no overflow, and matching reference composition.

