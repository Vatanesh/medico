import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/recording_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home/home_screen.dart';
import 'services/api/api_service.dart';
import 'models/queued_chunk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);
  
  // Register Hive adapters
  Hive.registerAdapter(QueuedChunkAdapter());
  
  // Initialize API Service
  await ApiService().initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => RecordingProvider()),
      ],
      child: const MediNoteApp(),
    ),
  );
}

class MediNoteApp extends StatelessWidget {
  const MediNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            return MaterialApp(
              title: 'MediNote',
              debugShowCheckedModeBanner: false,
              
              // Theme
              theme: AppTheme.lightTheme(lightDynamic),
              darkTheme: AppTheme.darkTheme(darkDynamic),
              themeMode: themeProvider.themeMode,
              
              // Localization
              locale: localeProvider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'), // English
                Locale('hi'), // Hindi
              ],
              
              // Home
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}
