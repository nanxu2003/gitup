# Two-Phase Game UI Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild the four screenshot-inspired game pages from modular generated art, remove all reference screenshots, then extend the same image-backed visual system to every remaining game page without adding recharge UI.

**Architecture:** Introduce a typed asset contract and reusable image-backed scaffold. Compose scene backgrounds, transparent character art, Flutter-rendered panels, and dynamic game data in responsive stacks; preserve all existing services, models, routes, and persistence.

**Tech Stack:** Flutter/Dart, Material widgets, widget tests, bundled PNG assets, existing `GameSave`, `BattleEngine`, `RecruitService`, and `SaveService`.

---

### Task 1: Establish the modular game-art contract

**Files:**
- Create: `lib/app/game_art.dart`
- Create: `test/app/game_art_contract_test.dart`
- Modify: `pubspec.yaml`

**Step 1: Write the failing asset-contract test**

Test that every `GameArt` path exists, that production Dart and `pubspec.yaml` contain no `_reference.png`, and that all four backgrounds plus six characters and the item sheet have distinct semantic paths.

**Step 2: Run the test to verify it fails**

Run: `flutter test test/app/game_art_contract_test.dart`

Expected: FAIL because `GameArt` does not exist and reference filenames are still present.

**Step 3: Add semantic constants**

Create constants for:

```dart
abstract final class GameArt {
  static const worldMapBackground = 'assets/images/backgrounds/world_map.png';
  static const battlefieldBackground = 'assets/images/backgrounds/battlefield.png';
  static const recruitHallBackground = 'assets/images/backgrounds/recruit_hall.png';
  static const loginRewardBackground = 'assets/images/backgrounds/login_reward.png';
  static const mapGuide = 'assets/images/characters/map_guide.png';
  static const battleHero = 'assets/images/characters/battle_hero.png';
  static const battleRival = 'assets/images/characters/battle_rival.png';
  static const recruitLady = 'assets/images/characters/recruit_lady.png';
  static const recruitWarrior = 'assets/images/characters/recruit_warrior.png';
  static const loginLvbu = 'assets/images/characters/login_lvbu.png';
  static const rewardItems = 'assets/images/items/reward_items.png';
}
```

Register semantic asset directories in `pubspec.yaml`.

**Step 4: Commit the contract and test**

```bash
git add lib/app/game_art.dart test/app/game_art_contract_test.dart pubspec.yaml
git commit -m "test: define modular game art contract"
```

### Task 2: Prepare generated images for runtime composition

**Files:**
- Create: `assets/images/backgrounds/world_map.png`
- Create: `assets/images/backgrounds/battlefield.png`
- Create: `assets/images/backgrounds/recruit_hall.png`
- Create: `assets/images/backgrounds/login_reward.png`
- Create: `assets/images/characters/map_guide.png`
- Create: `assets/images/characters/battle_hero.png`
- Create: `assets/images/characters/battle_rival.png`
- Create: `assets/images/characters/recruit_lady.png`
- Create: `assets/images/characters/recruit_warrior.png`
- Create: `assets/images/characters/login_lvbu.png`
- Create: `assets/images/items/reward_items.png`

**Step 1: Copy the four generated backgrounds to semantic paths**

Map the existing generated files as follows:

- `exec-310c15cb-1574-44da-82e3-37f2eb603617.png` → world map.
- `exec-6fffdf95-fadd-426f-b53f-69c8203eb45a.png` → battlefield.
- `exec-9904fc06-97ff-44c4-974e-5539dc7dc3d7.png` → recruit hall.
- `exec-b7ee7397-3a96-449f-94f8-5e3a063409a0.png` → login reward.

**Step 2: Remove green backgrounds from the six generated characters**

Use the `imagegen` editing workflow on each source, preserving the subject exactly and producing transparent PNG output:

- `exec-fe4f36e4-0c0e-4887-aed7-ab32f975910b.png` → map guide.
- `exec-a38078b7-d01a-4fbc-b171-b47e486d1b46.png` → battle hero.
- `exec-7dd63013-c3ce-4d5f-b892-a726c09492de.png` → battle rival.
- `exec-14c1b519-1029-4570-96ab-b85aa8a0fcdd.png` → recruit lady.
- `exec-6772566a-ba2c-4a11-9cfa-10a6001f3061.png` → recruit warrior.
- `exec-f5e0c748-f3d1-4275-8328-60f265e1c2de.png` → login Lü Bu.

**Step 3: Remove the magenta background from the item sheet**

Use the same transparent-background editing workflow for `exec-192cfcd0-95df-4190-9612-30c14e25a442.png`.

**Step 4: Inspect all outputs**

Verify dimensions, alpha corners, edge halos, subject cropping, and Flutter PNG decoding.

**Step 5: Run the asset test**

Run: `flutter test test/app/game_art_contract_test.dart`

Expected: reference-name assertion still fails until Task 6, but all semantic path existence assertions pass.

**Step 6: Commit semantic art**

```bash
git add assets/images/backgrounds assets/images/characters assets/images/items
git commit -m "feat: add modular generated game art"
```

### Task 3: Add reusable layered visual components

**Files:**
- Create: `lib/widgets/game_art_layer.dart`
- Create: `lib/widgets/game_backdrop_scaffold.dart`
- Create: `lib/widgets/game_item_icon.dart`
- Create: `test/widgets/game_art_layer_test.dart`
- Create: `test/widgets/game_backdrop_scaffold_test.dart`
- Create: `test/widgets/game_item_icon_test.dart`
- Modify: `lib/widgets/ornate_game_frame.dart`

**Step 1: Write failing widget tests**

Cover background error fallback, character alignment and clipping, readable overlay opacity, safe-area body placement, sprite selection, and rarity border.

**Step 2: Run tests and verify failure**

Run: `flutter test test/widgets/game_art_layer_test.dart test/widgets/game_backdrop_scaffold_test.dart test/widgets/game_item_icon_test.dart`

Expected: FAIL because the widgets do not exist.

**Step 3: Implement the components**

- `GameArtLayer`: `Image.asset` plus semantic-keyed fallback and optional foreground fade.
- `GameBackdropScaffold`: background image, configurable scrim, `SafeArea`, optional header and foreground layers.
- `GameItemIcon`: clip the 4×2 item atlas with code-rendered rarity frame.
- Refine `OrnateGameFrame` to use consistent dark lacquer, old-gold borders, inner highlights, and responsive padding.

**Step 4: Run focused tests**

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/widgets test/widgets
git commit -m "feat: add layered game UI primitives"
```

### Task 4: Rebuild the world map and battle pages

**Files:**
- Modify: `lib/screens/world_map_screen.dart`
- Modify: `lib/screens/battle_screen.dart`
- Modify: `test/screens/world_map_screen_test.dart`
- Modify: `test/screens/battle_screen_test.dart`

**Step 1: Extend failing tests**

Require `GameArt.worldMapBackground`, `GameArt.mapGuide`, `GameArt.battlefieldBackground`, and both battle character layers. Keep assertions for stage selection, target selection, skills, auto battle, and navigation.

**Step 2: Run focused tests and verify failure**

Run: `flutter test test/screens/world_map_screen_test.dart test/screens/battle_screen_test.dart`

**Step 3: Recompose the world map**

Use the generated floating-mountain background, existing relative stage positions, code-native status markers, a left-bottom guide character, and an opaque stage detail sheet that stays above the safe area.

**Step 4: Recompose the battle page**

Use the burning battlefield, compact encounter HUD, two responsive formations, floating combat pulse, code-native health/energy bars, and bottom-edge hero/rival art that does not block command buttons.

**Step 5: Run focused tests**

Expected: PASS.

**Step 6: Commit**

```bash
git add lib/screens/world_map_screen.dart lib/screens/battle_screen.dart test/screens/world_map_screen_test.dart test/screens/battle_screen_test.dart
git commit -m "feat: rebuild map and battle with modular art"
```

### Task 5: Rebuild recruitment and login rewards

**Files:**
- Modify: `lib/screens/recruit_screen.dart`
- Modify: `lib/widgets/login_reward_overlay.dart`
- Modify: `test/screens/recruit_screen_test.dart`
- Modify: `test/widgets/login_reward_overlay_test.dart`

**Step 1: Extend failing tests**

Require the recruit and login backgrounds, character layers, item icons, four dynamic candidate cards, three reward days, claim state, and absence of recharge/payment copy.

**Step 2: Run focused tests and verify failure**

Run: `flutter test test/screens/recruit_screen_test.dart test/widgets/login_reward_overlay_test.dart`

**Step 3: Recompose recruitment**

Layer the recruit hall, central recruit lady, lower-edge dark warrior, red-gold panel, featured cards, pity progress, and existing resource-based recruit actions. Do not add recharge or purchase controls.

**Step 4: Recompose login rewards**

Layer the fire-mountain background and Lü Bu art behind a three-day reward stage. Use `GameItemIcon` and retain local claim/persistence behavior. Use only free-login wording.

**Step 5: Run focused tests**

Expected: PASS.

**Step 6: Commit**

```bash
git add lib/screens/recruit_screen.dart lib/widgets/login_reward_overlay.dart test/screens/recruit_screen_test.dart test/widgets/login_reward_overlay_test.dart
git commit -m "feat: rebuild recruit and login reward stages"
```

### Task 6: Remove the four reference screenshots and verify phase one

**Files:**
- Delete: `assets/images/world_map_reference.png`
- Delete: `assets/images/battle_reference.png`
- Delete: `assets/images/recruit_reference.png`
- Delete: `assets/images/login_reward_reference.png`
- Modify: `test/app/game_art_contract_test.dart`

**Step 1: Delete the files only after screen migrations pass**

Remove all four files and use `rg` to verify no reference remains in `lib`, `test`, or `pubspec.yaml`.

**Step 2: Run phase-one tests**

Run: `flutter test test/app/game_art_contract_test.dart test/screens/world_map_screen_test.dart test/screens/battle_screen_test.dart test/screens/recruit_screen_test.dart test/widgets/login_reward_overlay_test.dart`

Expected: PASS.

**Step 3: Run static checks**

Run: `dart format lib test && flutter analyze`

Expected: no new diagnostics.

**Step 4: Commit**

```bash
git add -A assets/images lib test pubspec.yaml
git commit -m "chore: remove screenshot reference assets"
```

### Task 7: Apply the image-backed scaffold to all remaining game pages

**Files:**
- Modify: `lib/screens/home_screen.dart`
- Modify: `lib/screens/city_screen.dart`
- Modify: `lib/screens/politics_screen.dart`
- Modify: `lib/screens/general_list_screen.dart`
- Modify: `lib/screens/general_detail_screen.dart`
- Modify: `lib/screens/formation_screen.dart`
- Modify: `lib/screens/inventory_screen.dart`
- Modify: `lib/screens/quest_screen.dart`
- Modify: `lib/screens/quest_dialog_screen.dart`
- Modify: `lib/screens/story_event_screen.dart`
- Modify: `lib/screens/battle_result_screen.dart`
- Modify: `lib/screens/splash_screen.dart`
- Modify: `lib/screens/create_player_screen.dart`
- Modify: `lib/screens/settings_screen.dart`
- Modify: `lib/screens/help_screen.dart`
- Modify: `lib/screens/feedback_screen.dart`
- Modify: `lib/screens/about_screen.dart`
- Modify: `lib/screens/user_agreement_screen.dart`
- Modify: `lib/screens/privacy_policy_screen.dart`
- Create: `test/app/all_screens_backdrop_test.dart`

**Step 1: Write a failing coverage test**

Scan production screen sources and require every full-page screen to use `GameBackdropScaffold`, an explicit `GameArtLayer`, or a documented splash-specific image background.

**Step 2: Run the coverage test and verify failure**

Run: `flutter test test/app/all_screens_backdrop_test.dart`

**Step 3: Convert gameplay pages by visual family**

- Palace: home, city, politics, generals, inventory, recruitment.
- World/fire: quests, story events, quest dialog.
- Battlefield: formation and battle result.
- Low-contrast palace: settings, help, feedback, about, agreements, privacy.
- Intro composition: splash and create-player.

Preserve existing app bars, callbacks, forms, dialogs, routing, scrolling, and save behavior. Wrap content in readable lacquer panels rather than changing business logic.

**Step 4: Run coverage and existing tests**

Expected: PASS with no layout exceptions.

**Step 5: Commit in two logical groups**

```bash
git commit -m "feat: add backgrounds to gameplay pages"
git commit -m "feat: add backgrounds to support pages"
```

### Task 8: Final verification and visual polish

**Files:**
- Modify only files implicated by verification failures.

**Step 1: Search for forbidden content and stale references**

Run:

```bash
rg -n "_reference\\.png|充值|首充|付费|购买礼包" lib test pubspec.yaml
```

Expected: no production UI matches.

**Step 2: Format and analyze**

Run: `dart format lib test && flutter analyze`

Expected: no diagnostics.

**Step 3: Run the full test suite**

Run: `flutter test`

Expected: all tests pass.

**Step 4: Build and inspect**

Build for an available simulator, open the four key pages first, then representative pages from each visual family. Check image decoding, transparency, safe areas, scrolling, text contrast, tap targets, and overflow.

**Step 5: Commit verification fixes**

```bash
git add lib test assets pubspec.yaml
git commit -m "fix: polish responsive game UI"
```
