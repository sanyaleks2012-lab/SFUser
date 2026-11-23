import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:log_plus/log_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sfuser/app.dart';
import 'package:sfuser/logic/game_package.dart';
import 'package:sfuser/themes.dart';
import 'package:sfuser/ui/glass.dart';

Logs constructLogger() {
  return logger = Logs(
    storeLogLevel: LogLevel.verbose,
    printLogLevelWhenDebug: LogLevel.verbose,
    printLogLevelWhenRelease: LogLevel.verbose,
    storeLimit: 500,
  );
}

var logger = constructLogger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadPrefsValues();
  runApp(const RootApp());
}

Future<void> loadPrefsValues() async {
  final prefs = await SharedPreferences.getInstance();
  await loadThemeFromPrefs(prefs);
  loadGamePackageFromPrefs(prefs);
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) {
        final brightness_ = brightness.value;
        final useSystemColors_ = useSystemColors.value;
        final primaryColor_ = primaryColor.value;
        return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          ColorScheme lightColorScheme;
          ColorScheme darkColorScheme;

          if (lightDynamic != null && darkDynamic != null && useSystemColors_) {
            lightColorScheme = ColorScheme.fromSeed(
                seedColor: lightDynamic.primary, brightness: Brightness.light);
            darkColorScheme = ColorScheme.fromSeed(
                seedColor: darkDynamic.primary, brightness: Brightness.dark);
          } else {
            lightColorScheme = ColorScheme.fromSeed(seedColor: primaryColor_);
            darkColorScheme = ColorScheme.fromSeed(
                seedColor: primaryColor_, brightness: Brightness.dark);
          }

          supportsDynamicColors.value =
              lightDynamic != null && darkDynamic != null;

          final lightTheme = ThemeData(
              colorScheme: lightColorScheme,
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.transparent,
              appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  scrolledUnderElevation: 0));

          final darkTheme = ThemeData(
              colorScheme: darkColorScheme,
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.transparent,
              appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  scrolledUnderElevation: 0));
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: brightness_,
              title: "SFUser",
              builder: (context, child) => GlassBackground(child: child!),
              home: const App());
        });
      },
    );
  }
}
