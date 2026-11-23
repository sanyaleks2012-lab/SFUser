import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';

/// Shadow Fight 2 packages the app can read saves from.
const List<String> gamePackages = ["com.onerdna.sfml", "com.sf2.de"];
const String defaultGamePackage = "com.onerdna.sfml";

/// Package of the game whose save folder is used (/sdcard/Android/data/<pkg>/...).
final Signal<String> gamePackage = signal(defaultGamePackage);

void loadGamePackageFromPrefs(SharedPreferences prefs) {
  final saved = prefs.getString("gamePackage");
  gamePackage.value =
      saved != null && gamePackages.contains(saved) ? saved : defaultGamePackage;
}

Future<void> setGamePackage(String value) async {
  gamePackage.value = value;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("gamePackage", value);
}
