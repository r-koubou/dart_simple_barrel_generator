import 'dart:io';

import 'package:glob/glob.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import './config.dart';
import './path_util.dart';

class FileCollector {
  /// Collects all Dart source files in the given directory recursively.
  Future<List<File>> collect(Config config) async {
    final result = <File>[];
    final directoryPath = config.directory;
    final directory = Directory(directoryPath);
    final includes = config.includePatterns;
    final excludes = config.excludePatterns;

    if (!await directory.exists()) {
      return const [];
    }

    final includeGlobs = _createGlobs(directoryPath, includes);
    final excludeGlobs = _createGlobs(directoryPath, excludes);

    Logger.root.fine('Collecting files from directory: $directory');
    Logger.root.fine('Include patterns: $includeGlobs');
    Logger.root.fine('Exclude patterns: $excludeGlobs');

    await for (final entity in directory.list(recursive: true)) {
      if (entity is! File) {
        continue;
      }

      final normalizedFilePath = notmalizeAbsPathAsPosix(entity.path);

      Logger.root.fine('Checking file: $normalizedFilePath');

      if (excludeGlobs.any((glob) => glob.matches(normalizedFilePath))) {
        Logger.root.fine('Found in exclude patterns: ${entity.path}');
        continue;
      }

      if (!includeGlobs.any((glob) {
        Logger.root.fine('include pattern: $glob');
        Logger.root.fine('matched: ${glob.matches(normalizedFilePath)}');
        return glob.matches(normalizedFilePath);
      })) {
        Logger.root.fine('Not found in include patterns: ${entity.path}');
        continue;
      }

      Logger.root.fine('Adding file: ${entity.path}');

      result.add(entity);
    }

    return result
      ..sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
  }

  List<Glob> _createGlobs(String directoryPath, List<String> patterns) {
    final globs = <Glob>[];
    for (final pattern in patterns) {
      final globPath =
          notmalizeAbsPathAsPosix(path.join(directoryPath, pattern));
      globs.add(Glob(globPath));
    }
    return globs;
  }
}
