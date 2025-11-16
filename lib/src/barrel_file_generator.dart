import 'dart:io';

import 'package:path/path.dart' as path;

import 'config.dart';

class BarrelFileGenerator {
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
        if (file.path == barrelFilePath) {
          continue;
        }
        final relativePath = path.relative(file.path, from: directory);
        sink.writeln("export '$relativePath';");
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
  }
}
