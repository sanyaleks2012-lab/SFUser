import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sfuser/shizuku_api.dart';
import 'package:sfuser/shizuku_file.dart';

/// Shared data folder on the device, readable and editable by the user:
///
///   /sdcard/SFUser/enchantment/*.toml  <- assets/enchantments/
///   /sdcard/SFUser/data/*.toml         <- assets/item_database/ and assets/traits.toml
///
/// The bundled assets are copied there on every start-up. After that, all
/// reads go to this folder (through the Shizuku shell), not to the bundle.
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
      final output = await BridgeApi.runCommand("mkdir -p ${pathOf(dir)}");
      if (output != null && output.isNotEmpty) {
        throw FileSystemException("Unable to create ${pathOf(dir)}", output);
      }
    }

    for (final asset in assets) {
      final dir = _destinationFor(asset);
      if (dir == null) continue;
      final contents = await rootBundle.loadString(asset);
      await writeFile("${pathOf(dir)}/${asset.split('/').last}", contents);
    }
  }

  /// Full paths of all toml files in [root]/[dir], sorted by name.
  static Future<List<String>> listTomlFiles(String dir) async {
    final output = await BridgeApi.runCommand("ls -1 ${pathOf(dir)}") ?? "";
    final names = output
        .split("\n")
        .map((line) => line.trim())
        .where((name) => name.endsWith(".toml"))
        .toList()
      ..sort();
    return names.map((name) => "${pathOf(dir)}/$name").toList();
  }
}
