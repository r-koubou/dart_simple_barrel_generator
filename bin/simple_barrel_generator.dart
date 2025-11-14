import 'dart:io';

import 'package:args/args.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  try {
    final config = await parseCommandArguments(args);
    await generate(config);
  } on ArgParserException catch (_) {
    exit(1);
  } on ArgumentError catch (_) {
    exit(1);
  }
}

Future<BarrelConfig> parseCommandArguments(Iterable<String> args) async {
  final parser = ArgParser();

  try {
    parser
      ..addOption('base-dir',
          abbr: 'b',
          mandatory: true,
          help: 'The root directory of source files.')
      ..addOption('prefix',
          abbr: 'p',
          help: 'The prefix for the barrel file name.',
          mandatory: true)
      ..addOption('includes',
          abbr: 'i', help: 'Comma-separated list of glob patterns to include.')
      ..addOption('excludes',
          abbr: 'e', help: 'Comma-separated list of glob patterns to exclude.')
      ..addFlag('help', abbr: 'h', help: 'Show usage.', negatable: false);

    final parseResult = parser.parse(args);

    if (parseResult['help'] as bool) {
      usage(parser.usage);
      exit(0);
    }

    var config = BarrelConfig(
        directory: parseResult['base-dir'] as String,
        prefix: parseResult['prefix'] as String);

    if (parseResult.wasParsed('includes')) {
      final includes = (parseResult['includes'] as String)
          .split(',')
          .map((e) => e.trim())
          .toList();
      config = config.copyWith(includePatterns: includes);
    }
    if (parseResult.wasParsed('excludes')) {
      final excludes = (parseResult['excludes'] as String)
          .split(',')
          .map((e) => e.trim())
          .toList();
      config = config.copyWith(excludePatterns: excludes);
    }

    return config;
  } on ArgParserException catch (e) {
    stderr.writeln('Error: ${e.message}');
    usage(parser.usage);
    rethrow;
  } on ArgumentError catch (e) {
    stderr.writeln('Error: ${e.message}');
    usage(parser.usage);
    rethrow;
  }
}

Future<void> generate(BarrelConfig config) async {
  await generateImpl(
    directory: config.directory,
    barrelPrefix: p.basename(config.prefix),
    includeExtensions: config.includePatterns,
    excludeExtensions: config.excludePatterns,
  );
}

/// Generates a barrel file in the specified directory with the given prefix.
Future<void> generateImpl({
  required String directory,
  required String barrelPrefix,
  List<String> includeExtensions = const [],
  List<String> excludeExtensions = const [],
}) async {
  final files = await collectSourceFiles(
    directory,
    includes: includeExtensions,
    excludes: excludeExtensions,
  );

  if (files.isEmpty) {
    stdout.writeln(
      '[!] No source files found in $directory. Skipping barrel generation.',
    );
    return;
  }

  final barrelFilePath = p.join(directory, '$barrelPrefix.dart');

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
      final relativePath = p.relative(file.path, from: directory);
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
  List<String> includes = const [],
  List<String> excludes = const [],
}) async {
  final result = <File>[];
  final directory = Directory(directoryPath);

  if (!await directory.exists()) {
    return const [];
  }

  List<Glob> createBlob(List<String> patterns) {
    final globs = <Glob>[];
    for (final pattern in patterns) {
      globs.add(Glob('$directoryPath/$pattern'));
    }
    return globs;
  }

  final includeGlobs = createBlob(includes);
  final excludeGlobs = createBlob(excludes);

  await for (final entity in directory.list(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    if (excludeGlobs.any((glob) => glob.matches(entity.path))) {
      continue;
    }

    if (includeGlobs.isNotEmpty &&
        !includeGlobs.any((glob) => glob.matches(entity.path))) {
      continue;
    }

    result.add(entity);
  }

  return result;
}

/// Prints usage information.
void usage(String usageText) {
  stdout.writeln('Usage: dart run simple_barrel_generator <options>');
  stdout.writeln(usageText);
}

/// Configuration for barrel file generation.
class BarrelConfig {
  static const String defaultPackageDirectory = '.';
  static const defaultIncludes = ['**.dart'];
  static const defaultExcludes = [
    '**.g.dart',
    '**.freezed.dart',
    '**.part.dart'
  ];

  final String directory;
  final String prefix;
  final List<String> includePatterns;
  final List<String> excludePatterns;

  BarrelConfig({
    required this.directory,
    required this.prefix,
    this.includePatterns = defaultIncludes,
    this.excludePatterns = defaultExcludes,
  });

  BarrelConfig copyWith({
    String? directory,
    String? barrelPrefix,
    List<String>? includePatterns,
    List<String>? excludePatterns,
  }) {
    return BarrelConfig(
      directory: directory ?? this.directory,
      prefix: barrelPrefix ?? prefix,
      includePatterns: includePatterns ?? this.includePatterns,
      excludePatterns: excludePatterns ?? this.excludePatterns,
    );
  }
}
