import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app_theme.dart';
import 'app/app_router.dart';
import 'services/storage_service.dart';
import 'services/save_service.dart';

late StorageService storageService;
late SaveService saveService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  storageService = StorageService(prefs);
  saveService = SaveService(storageService);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '星落五丈原',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.gameTheme(),
      initialRoute: '/',
      onGenerateRoute: (settings) =>
          AppRouter.generateRoute(settings, storageService, saveService),
    );
  }
}
