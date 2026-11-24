import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:sfuser/shizuku_api.dart';

Future<String> readFile(String path) async {
  try {
    return await File(path).readAsString();
  } on FileSystemException {
    // Not readable directly (Android/data on Android 11+): use Shizuku below
  }

  final Directory directory = (await getExternalStorageDirectory())!;

  final file = makeTempFile(directory.path);

  validateCpOutput(
      file.path, await BridgeApi.runCommand("cp $path ${file.path}"));

  final contents = await file.readAsString();
  await BridgeApi.runCommand("rm ${file.path}");

  return contents;
}

String validateCpOutput(String path, String? output) {
  if (output == null) {
    throw FileSystemException('Unable to read file: unknown error', path);
  }

  if (output == 'cp: $path: No such file or directory') {
    throw FileSystemException('File does not exist', path);
  } else if (output == 'cp: $path: Permission denied') {
    throw FileSystemException('Permission denied', path);
  } else if (output == 'cp: $path: Is a directory') {
    throw FileSystemException('Path is a directory, not a file', path);
  }

  return output;
}

File makeTempFile(String path) {
  final rnd = List.generate(
      10,
      (_) => 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[
          Random().nextInt(62)]).join();
  return File("$path/.temp$rnd");
}

Future<void> writeFile(String targetPath, String contents) async {
  try {
    await File(targetPath).writeAsString(contents, flush: true);
    return;
  } on FileSystemException {
    // Not writable directly: use Shizuku below
  }

  final directory = (await getExternalStorageDirectory())!;
  final file = makeTempFile(directory.path);
  await file.writeAsString(contents);
  validateCpOutput(
      targetPath, await BridgeApi.runCommand("cp ${file.path} $targetPath"));
  await BridgeApi.runCommand("rm ${file.path}");
}

/// Copies a file, directly if allowed, otherwise through the Shizuku shell.
Future<void> copyFile(String source, String target) async {
  try {
    await File(source).copy(target);
    return;
  } on FileSystemException {
    // Fall back to Shizuku below
  }
  validateCpOutput(source, await BridgeApi.runCommand("cp $source $target"));
}
