# Realistic Cartoon Game UI System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace generic Material presentation with a reusable image-driven realistic-cartoon Three Kingdoms UI across the Flutter game.

**Architecture:** Generate modular atlases for UI chrome, feature icons, buildings, and portraits, then expose them through a typed asset contract. Build reusable Flutter widgets for surfaces, buttons, feature entries, resources, banners, and portraits; migrate pages by visual family without changing business logic.

**Tech Stack:** Flutter/Dart, bundled PNG assets, image generation with chroma-key post-processing, widget tests, existing game models and services.

---

### Task 1: Define the new art contract

**Files:**
- Create: `lib/app/game_ui_art.dart`
- Create: `test/app/game_ui_art_contract_test.dart`
- Modify: `pubspec.yaml`

1. Write a failing test for UI chrome, feature icon, building, and portrait asset paths.
2. Run `flutter test --no-pub test/app/game_ui_art_contract_test.dart` and confirm failure.
3. Add semantic constants and register asset directories.
4. Run the test after assets are produced.

### Task 2: Generate modular art batches

**Files:**
- Create: `assets/images/ui/game_ui_chrome.png`
- Create: `assets/images/icons/feature_icons.png`
- Create: `assets/images/buildings/building_tiles.png`
- Create: `assets/images/portraits/general_portraits.png`

1. Use the `imagegen` skill to generate four text-free sheets in the established realistic-cartoon Three Kingdoms style.
2. Use a flat chroma-key background where transparency is needed and remove it with the bundled helper.
3. Inspect alpha, cell alignment, cropping, text contamination, and edge halos.
4. Run the asset contract test.

### Task 3: Build the shared game UI component layer

**Files:**
- Create: `lib/widgets/game_surface.dart`
- Create: `lib/widgets/game_action_button.dart`
- Create: `lib/widgets/game_feature_tile.dart`
- Create: `lib/widgets/game_portrait.dart`
- Modify: `lib/widgets/resource_bar.dart`
- Modify: `lib/widgets/section_header.dart`
- Modify: `lib/widgets/styled_button.dart`
- Create: `test/widgets/game_ui_components_test.dart`

1. Write failing tests for image-backed surfaces, buttons, tiles, portraits, fallbacks, and semantic labels.
2. Implement atlas cells and code-rendered borders/states.
3. Add press scale and selected glow without blocking taps.
4. Run focused widget tests.

### Task 4: Rebuild the home page as an illustrated city hub

**Files:**
- Modify: `lib/screens/home_screen.dart`
- Modify: `test/app/all_screens_backdrop_test.dart`
- Create: `test/screens/home_screen_test.dart`

1. Test the military resource bar, illustrated feature entries, badges, and end-day action.
2. Replace the plain grid with an image-backed city hub using `GameFeatureTile`.
3. Preserve navigation, save, login reward, resource, and end-day behavior.
4. Verify at 390×844 and 430×932 logical sizes.

### Task 5: Upgrade city, politics, generals, formation, and inventory

**Files:**
- Modify: `lib/screens/city_screen.dart`
- Modify: `lib/screens/politics_screen.dart`
- Modify: `lib/screens/general_list_screen.dart`
- Modify: `lib/screens/general_detail_screen.dart`
- Modify: `lib/screens/formation_screen.dart`
- Modify: `lib/screens/inventory_screen.dart`
- Modify: `lib/widgets/general_card.dart`

1. Add building art to city cards and scroll/edict styling to politics actions.
2. Add portrait art, camp/quality frames, and troop badges to general and formation cards.
3. Add illustrated item slots and rarity frames to inventory.
4. Preserve all callbacks and mutations; run existing and new widget tests.

### Task 6: Upgrade quests, story, battle, recruitment, and rewards

**Files:**
- Modify: `lib/screens/quest_screen.dart`
- Modify: `lib/screens/quest_dialog_screen.dart`
- Modify: `lib/screens/story_event_screen.dart`
- Modify: `lib/screens/world_map_screen.dart`
- Modify: `lib/screens/battle_screen.dart`
- Modify: `lib/screens/battle_result_screen.dart`
- Modify: `lib/screens/recruit_screen.dart`
- Modify: `lib/widgets/login_reward_overlay.dart`

1. Apply banners, quest scrolls, reward icons, metal HUDs, portrait frames, and unified action buttons.
2. Keep current background and character compositions.
3. Verify return/close controls remain anchored to safe-area edges.
4. Run all page-focused tests.

### Task 7: Upgrade support and reading pages

**Files:**
- Modify: `lib/screens/settings_screen.dart`
- Modify: `lib/screens/help_screen.dart`
- Modify: `lib/screens/feedback_screen.dart`
- Modify: `lib/screens/about_screen.dart`
- Modify: `lib/screens/user_agreement_screen.dart`
- Modify: `lib/screens/privacy_policy_screen.dart`
- Modify: `lib/screens/splash_screen.dart`
- Modify: `lib/screens/create_player_screen.dart`

1. Use low-contrast art, parchment reading surfaces, icon rows, and unified action buttons.
2. Keep long-form content readable and scrollable.
3. Verify forms, dialogs, navigation, and safe areas.

### Task 8: Final validation

1. Run `dart format` only on changed Dart files.
2. Run `flutter test --no-pub` and require zero failures.
3. Run `flutter analyze --no-pub`; allow only the five previously documented info diagnostics.
4. Run `flutter build ios --simulator --no-pub`.
5. Inspect representative pages from every visual family on iPhone 17 Pro.
