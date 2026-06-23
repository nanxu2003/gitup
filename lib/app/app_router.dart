import 'package:flutter/material.dart';
import '../models/game_save.dart';
import '../models/battle.dart';
import '../models/general.dart';
import '../services/storage_service.dart';
import '../services/save_service.dart';
import '../screens/splash_screen.dart';
import '../screens/create_player_screen.dart';
import '../screens/home_screen.dart';
import '../screens/city_screen.dart';
import '../screens/politics_screen.dart';
import '../screens/general_list_screen.dart';
import '../screens/general_detail_screen.dart';
import '../screens/formation_screen.dart';
import '../screens/battle_screen.dart';
import '../screens/battle_result_screen.dart';
import '../screens/world_map_screen.dart';
import '../screens/recruit_screen.dart';
import '../screens/quest_screen.dart';
import '../screens/quest_dialog_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/story_event_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';
import '../screens/user_agreement_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/help_screen.dart';
import '../screens/feedback_screen.dart';
import 'game_route.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(
    RouteSettings settings,
    StorageService storageService,
    SaveService saveService,
  ) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return GameFadeRoute(
          settings: settings,
          builder: (_) => SplashScreen(
            saveService: saveService,
            storageService: storageService,
          ),
        );

      case '/create_player':
        return GamePageRoute(
          settings: settings,
          builder: (_) => CreatePlayerScreen(saveService: saveService),
        );

      case '/home':
        if (args is GameSave) {
          return GameFadeRoute(
            settings: settings,
            builder: (_) =>
                HomeScreen(gameSave: args, saveService: saveService),
          );
        }
        return _errorRoute();

      case '/city':
        if (args is GameSave) {
          return GamePageRoute(
            settings: settings,
            builder: (_) => CityScreen(gameSave: args),
          );
        }
        return _errorRoute();

      case '/politics':
        if (args is GameSave) {
          return GamePageRoute(
            settings: settings,
            builder: (_) => PoliticsScreen(gameSave: args),
          );
        }
        return _errorRoute();

      case '/generals':
        if (args is GameSave) {
          return GamePageRoute(
            settings: settings,
            builder: (_) => GeneralListScreen(gameSave: args),
          );
        }
        return _errorRoute();

      case '/general_detail':
        if (args is Map<String, dynamic>) {
          return GamePageRoute(
            settings: settings,
            builder: (_) => GeneralDetailScreen(
              general: args['general'] as General,
              gameSave: args['gameSave'] as GameSave,
            ),
          );
        }
        return _errorRoute();

      case '/formation':
        if (args is GameSave) {
          return GamePageRoute(
            settings: settings,
            builder: (_) => FormationScreen(gameSave: args),
          );
        }
        return _errorRoute();

      case '/battle':
        if (args is Map<String, dynamic>) {
          return GameFullScreenRoute(
            settings: settings,
            builder: (_) => BattleScreen(
              gameSave: args['gameSave'] as GameSave,
              enemyIds: (args['enemyIds'] as List<dynamic>).cast<String>(),
              stageId: args['stageId'] as String,
            ),
          );
        }
        return _errorRoute();

      case '/battle_result':
        if (args is Map<String, dynamic>) {
          return GameFadeRoute(
            settings: settings,
            builder: (_) => BattleResultScreen(
              result: args['result'] as BattleResult,
              gameSave: args['gameSave'] as GameSave,
              stageId: args['stageId'] as String,
            ),
          );
        }
        return _errorRoute();

      case '/world_map':
        if (args is GameSave) {
          return GamePageRoute(
            settings: settings,
            builder: (_) => WorldMapScreen(gameSave: args),
          );
        }
        return _errorRoute();

      case '/recruit':
        if (args is GameSave) {
          return GamePageRoute(
            settings: settings,
            builder: (_) => RecruitScreen(gameSave: args),
          );
        }
        return _errorRoute();

      case '/quests':
        if (args is GameSave) {
          return GamePageRoute(
            settings: settings,
            builder: (_) => QuestScreen(gameSave: args),
          );
        }
        return _errorRoute();

      case '/quest_dialog':
        if (args is Map<String, dynamic>) {
          return GameFadeRoute(
            settings: settings,
            builder: (_) => QuestDialogScreen(
              gameSave: args['gameSave'] as GameSave,
              eventId: args['eventId'] as String?,
            ),
          );
        }
        if (args is GameSave) {
          return GameFadeRoute(
            settings: settings,
            builder: (_) => QuestDialogScreen(gameSave: args),
          );
        }
        return _errorRoute();

      case '/inventory':
        if (args is GameSave) {
          return GamePageRoute(
            settings: settings,
            builder: (_) => InventoryScreen(gameSave: args),
          );
        }
        return _errorRoute();

      case '/story_event':
        if (args is GameSave) {
          return GameFadeRoute(
            settings: settings,
            builder: (_) => StoryEventScreen(gameSave: args),
          );
        }
        return _errorRoute();

      case '/settings':
        return GamePageRoute(
          settings: settings,
          builder: (_) => SettingsScreen(saveService: saveService),
        );

      case '/about':
        return GamePageRoute(
          settings: settings,
          builder: (_) => const AboutScreen(),
        );

      case '/user_agreement':
        return GamePageRoute(
          settings: settings,
          builder: (_) => const UserAgreementScreen(),
        );

      case '/privacy_policy':
        return GamePageRoute(
          settings: settings,
          builder: (_) => const PrivacyPolicyScreen(),
        );

      case '/help':
        return GamePageRoute(
          settings: settings,
          builder: (_) => const HelpScreen(),
        );

      case '/feedback':
        return GamePageRoute(
          settings: settings,
          builder: (_) => const FeedbackScreen(),
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('页面不存在', style: TextStyle(color: Colors.red[300])),
        ),
      ),
    );
  }
}
