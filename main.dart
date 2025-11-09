import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    usage();
    exit(1);
  }

  // load config from yaml file
  final yamlText = await File(args[0]).readAsString();
  final yaml = loadYaml(yamlText);
  final config = BarrelConfig.fromYaml(yaml);

  await generate(config);
}

Future<void> generate(BarrelConfig config) async {
  for (final x in config.directories) {
    final dirPath = p.join(config.baseDir, x);
    final prefix = p.basename(dirPath);
    await generateImpl(
      packageDirectoryPath: dirPath,
      preffix: prefix,
      sourceDirectoryName: config.sourceDirectoryName,
      includeExtensions: config.includeExtensions,
      excludeExtensions: config.excludeExtensions,
    );
  }
}

/// Generates a barrel file in the specified directory with the given prefix.
Future<void> generateImpl({
  required String packageDirectoryPath,
  required String preffix,
  required String sourceDirectoryName,
  List<String> includeExtensions = const [],
  List<String> excludeExtensions = const [],
}) async {
  final files = await collectSourceFiles(
    p.join(packageDirectoryPath, sourceDirectoryName),
    includeExtensions: includeExtensions,
    excludeExtensions: excludeExtensions,
  );

  final directoryPath = p.join(packageDirectoryPath, sourceDirectoryName);

  if (files.isEmpty) {
    stdout.writeln(
      '[!] No source files found in $directoryPath. Skipping barrel generation.',
    );
    return;
  }

  final barrelFilePath = p.join(directoryPath, '$preffix.dart');

  final barrelFile = File(barrelFilePath);
  final sink = barrelFile.openWrite();

  try {
    stdout.writeln('Generating barrel file at: $barrelFilePath');

    for (final file in files) {
      // Skip the barrel file itself
      if (file.path == barrelFilePath) {
        continue;
      }
      final relativePath = p.relative(file.path, from: directoryPath);
      sink.writeln("export '$relativePath';");
    }
  } finally {
    await sink.flush();
    await sink.close();
  }
}

/// Collects all Dart source files in the given directory recursively.
Future<List<File>> collectSourceFiles(
  String directoryPath, {
  List<String> includeExtensions = const [],
  List<String> excludeExtensions = const [],
}) async {
  final result = <File>[];
  final directory = Directory(directoryPath);

  if (!await directory.exists()) {
    return const [];
  }

  await for (final entity in directory.list(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    if (excludeExtensions.any((ext) => entity.path.endsWith(ext))) {
      continue;
    }
    if (includeExtensions.isNotEmpty &&
        !includeExtensions.any((ext) => entity.path.endsWith(ext))) {
      continue;
    }

    result.add(entity);
  }

  return result;
}

/// Prints usage information.
void usage() {
  stdout.writeln('Usage: dart main.dart config yaml path>');
}

/// Configuration for barrel file generation.
class BarrelConfig {
  final String baseDir;
  final String sourceDirectoryName;
  final List<String> directories;
  final List<String> includeExtensions;
  final List<String> excludeExtensions;

  BarrelConfig({
    required this.baseDir,
    required this.sourceDirectoryName,
    required this.directories,
    required this.includeExtensions,
    required this.excludeExtensions,
  });

  factory BarrelConfig.fromYaml(Map yaml) {
    return BarrelConfig(
      baseDir: yaml['base_dir'] ?? '.',
      sourceDirectoryName: yaml['source_directory_name'] ?? 'lib',
      directories: List<String>.from(yaml['directories'] ?? []),
      includeExtensions:
          List<String>.from(yaml['include_extensions'] ?? ['.dart']),
      excludeExtensions: List<String>.from(yaml['exclude_extensions'] ??
          ['.g.dart', '.freezed.dart', '.part.dart']),
    );
  }

  @override
  String toString() {
    final StringBuffer sb = StringBuffer();

    void toListString(StringBuffer sb, String title, List<String> items) {
      sb.writeln('$title:');
      for (final item in items) {
        sb.writeln('  - $item');
      }
    }

    sb.writeln('[${runtimeType.toString()}]');
    sb.writeln('baseDir: $baseDir');
    toListString(sb, 'directories', directories);
    toListString(sb, 'includeExtensions', includeExtensions);
    toListString(sb, 'excludeExtensions', excludeExtensions);

    return sb.toString();
  }
}
