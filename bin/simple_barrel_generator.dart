import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:simple_barrel_generator/simple_barrel_generator.dart';

void main(List<String> args) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}\t${record.time}\t${record.message}');
  });

  try {
    final config = await parseCommandArguments(args);
    final collector = FileCollector();
    final files = await collector.collect(config);
    final generator = BarrelFileGenerator();

    await generator.generate(config, files);
  } on ArgParserException catch (_) {
    exit(1);
  } on ArgumentError catch (_) {
    exit(1);
  }
}

Future<Config> parseCommandArguments(Iterable<String> args) async {
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
      ..addFlag('help', abbr: 'h', help: 'Show usage.', negatable: false)
      ..addFlag('verbose',
          abbr: 'v', help: 'Enable verbose logging.', negatable: false);

    final parseResult = parser.parse(args);

    if (parseResult['help'] as bool) {
      usage(parser.usage);
      exit(0);
    }

    if (parseResult['verbose'] as bool) {
      Logger.root.level = Level.ALL;
    }

    var config = Config(
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

/// Prints usage information.
void usage(String usageText) {
  stdout.writeln('Usage: dart run simple_barrel_generator <options>');
  stdout.writeln(usageText);
}
