# Screenshot-Inspired Game Pages Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild the world map, battle, recruitment, and login reward experiences with the supplied screenshot artwork while preserving the current game systems.

**Architecture:** Add a small reusable visual component layer for ornamental frames, calligraphy headings, and image-backed stages. Each redesigned screen remains connected to the existing `GameSave`, `BattleEngine`, and `RecruitService`; a new home overlay handles local three-day login rewards.

**Tech Stack:** Flutter/Dart, Material widgets, existing setState architecture, bundled PNG assets, shared_preferences through the existing save service.

---

### Task 1: Prepare screenshot artwork assets

**Files:**
- Create: `assets/images/world_map_reference.png`
- Create: `assets/images/battle_reference.png`
- Create: `assets/images/login_reward_reference.png`
- Create: `assets/images/recruit_reference.png`
- Modify: `pubspec.yaml`

**Steps:**

1. Prepare app-local image assets from the four user-supplied screenshots, retaining their characters and environments.
2. Register `assets/images/` under Flutter assets.
3. Run `flutter pub get` and expect dependency resolution to succeed.

### Task 2: Add reusable ornate visual components

**Files:**
- Create: `lib/widgets/ornate_game_frame.dart`
- Create: `test/widgets/ornate_game_frame_test.dart`

**Steps:**

1. Write a widget test that mounts the frame and finds its title and child.
2. Run `flutter test test/widgets/ornate_game_frame_test.dart` and verify it fails because the widget is missing.
3. Implement `OrnateGameFrame`, `BrushTitle`, and small status marker helpers with responsive dimensions.
4. Run the test and expect it to pass.

### Task 3: Rebuild the world map presentation

**Files:**
- Modify: `lib/screens/world_map_screen.dart`
- Create: `test/screens/world_map_screen_test.dart`

**Steps:**

1. Write a widget test that constructs a minimal save and verifies the map heading and an unlocked stage node.
2. Run the test and verify the existing list design fails the new expectations.
3. Replace the chapter card list with an image-backed vertical map, relatively positioned stage nodes, lock/completion states, and a bottom stage detail sheet.
4. Preserve the existing story/battle navigation and grain checks.
5. Run the test and expect it to pass.

### Task 4: Rebuild the battle presentation

**Files:**
- Modify: `lib/screens/battle_screen.dart`
- Create: `test/screens/battle_screen_test.dart`

**Steps:**

1. Add a widget test for the battlefield heading, combatant panels, and battle controls.
2. Run it and verify it fails against the existing layout.
3. Restyle the page as an image-backed battlefield with top encounter HUD, compact health bars, floating combat text, and bottom hero/control overlay.
4. Keep all `BattleEngine` calls, target selection, auto battle, speed, and result navigation intact.
5. Run the test and expect it to pass.

### Task 5: Rebuild recruitment as a four-choice display

**Files:**
- Modify: `lib/screens/recruit_screen.dart`
- Create: `test/screens/recruit_screen_test.dart`

**Steps:**

1. Add a widget test for the brush heading, four candidate cards, cost, and recruit controls.
2. Run it and verify it fails against the current banner cards.
3. Build the red-gold recruitment stage and four responsive candidate cards over the supplied artwork.
4. Route all resource spending and results through the existing `RecruitService` methods.
5. Run the test and expect it to pass.

### Task 6: Add the three-day login reward overlay

**Files:**
- Create: `lib/widgets/login_reward_overlay.dart`
- Modify: `lib/screens/home_screen.dart`
- Create: `test/widgets/login_reward_overlay_test.dart`

**Steps:**

1. Add widget tests for three reward panels, claim state, and close action.
2. Run them and verify they fail because the overlay is missing.
3. Implement the screenshot-backed reward overlay and show it after the first home frame.
4. Add the day-one resources to `GameSave`, autosave, and prevent duplicate claims during the current home session.
5. Run the tests and expect them to pass.

### Task 7: Final verification and visual polish

**Files:**
- Modify: any redesigned file only when verification reveals an issue.

**Steps:**

1. Run `dart format lib test` and expect no formatting failures.
2. Run `flutter analyze` and fix every new diagnostic.
3. Run `flutter test` and expect the suite to pass.
4. Launch on the available iOS simulator, navigate through the four experiences, and capture screenshots.
5. Compare them against the references and adjust only spacing, contrast, clipping, and tap target issues.

