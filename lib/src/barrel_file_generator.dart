import 'dart:io';

import 'package:path/path.dart' as path;

import 'config.dart';
import 'path_util.dart';

/// Generates consolidated "barrel" Dart files that re-export selected library
/// units, streamlining imports and clarifying public API surfaces.
///
/// Core responsibilities:
/// - Discover eligible Dart source files under configured paths.
/// - Apply include/exclude filters and ordering rules.
/// - Emit deterministic, idempotent barrel files with clean export statements.
class BarrelFileGenerator {
  /// Generates a barrel file that exports all Dart files in the specified directory thar defined in [Config].
  Future<void> generate(Config config, List<File> files) async {
    if (files.isEmpty) {
      stdout.writeln('No files found in directory: ${config.directory}');
      return;
    }

    final directory = config.directory;
    final barrelPrefix = config.prefix;
    final barrelFilePath = path.join(directory, '$barrelPrefix.dart');

    final barrelFile = File(barrelFilePath);
    final sink = barrelFile.openWrite();

    try {
      stdout.writeln('Generating barrel file at: $barrelFilePath');

      sink.writeln('library;');
      sink.writeln();

      for (final file in files) {
        // Skip the barrel file itself
        if (path.absolute(file.path) == path.absolute(barrelFile.path)) {
          continue;
        }
        final relativePath =
            toPosixPathSeparator(path.relative(file.path, from: directory));

        sink.writeln("export '$relativePath';");
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
  }
}
