import 'dart:io';

import 'package:flutter/services.dart';

/// Shared data folder on the device, readable and editable by the user:
///
///   /sdcard/SFUser/enchantment/*.toml  <- assets/enchantments/
///   /sdcard/SFUser/data/*.toml         <- assets/item_database/ and assets/traits.toml
///
/// The bundled assets are copied there on every start-up. After that, the
/// data is read from this folder. Needs "all files" access (see StorageAccess).
class SfUserStorage {
  static const String root = "/sdcard/SFUser";
  static const String enchantmentDir = "enchantment";
  static const String dataDir = "data";

  static String pathOf(String dir) => "$root/$dir";

  static String dataPath(String fileName) => "${pathOf(dataDir)}/$fileName";

  /// Folder a bundled asset is copied into, or null if it is not synced.
  static String? _destinationFor(String asset) {
    if (!asset.endsWith(".toml")) return null;
    if (asset.startsWith("assets/enchantments/")) return enchantmentDir;
    if (asset.startsWith("assets/item_database/")) return dataDir;
    if (asset == "assets/traits.toml") return dataDir;
    return null;
  }

  /// Copies the bundled toml data into [root]. Existing files are overwritten
  /// so the folder always matches the version of the app that is running.
  static Future<void> syncAssets() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();

    final dirs = assets.map(_destinationFor).whereType<String>().toSet();
    for (final dir in dirs) {
      await Directory(pathOf(dir)).create(recursive: true);
    }

    for (final asset in assets) {
      final dir = _destinationFor(asset);
      if (dir == null) continue;
      final contents = await rootBundle.loadString(asset);
      final file = File("${pathOf(dir)}/${asset.split('/').last}");
      await file.writeAsString(contents, flush: true);
    }
  }

  /// Full paths of all toml files in [root]/[dir], sorted by name.
  static Future<List<String>> listTomlFiles(String dir) async {
    final directory = Directory(pathOf(dir));
    if (!await directory.exists()) return [];
    final paths = directory
        .listSync()
        .whereType<File>()
        .map((f) => f.path)
        .where((path) => path.endsWith(".toml"))
        .toList()
      ..sort();
    return paths;
  }

  static Future<String> readText(String path) => File(path).readAsString();
}
