import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:simple_barrel_generator/src/barrel_file_generator.dart';
import 'package:simple_barrel_generator/src/config.dart';
import 'package:simple_barrel_generator/src/file_collector.dart';
import 'package:test/test.dart';

final thisDirectory = path.dirname(Platform.script.toFilePath());
final testDataDir = path.join(thisDirectory, 'test_data');

final testPackageDir = path.join(testDataDir, 'packages', 'example');
final testDataLibDir = path.join(testPackageDir, 'lib');

void main() {
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}\t${record.time}\t${record.message}');
  });

  setUp(() async {
    final files = <FileSystemEntity>[
      Directory(testDataLibDir),
      File(path.join(testDataLibDir, 'src', 'a.dart')),
      File(path.join(testDataLibDir, 'src', 'b.dart')),
      File(path.join(testDataLibDir, 'src', 'c.g.dart')),
      File(path.join(testDataLibDir, 'src', 'd.freezed.dart')),
      File(path.join(testDataLibDir, 'src', 'e.part.dart')),
    ];

    for (final filePath in files) {
      if (filePath is Directory) {
        await filePath.create(recursive: true);
      } else if (filePath is File) {
        await filePath.create(recursive: true);
      }
    }
  });

  tearDown(() async {
    final dir = Directory(testDataDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  void printOnFailureFiles(List<File> files) {
    final buffer = StringBuffer();
    for (final file in files) {
      buffer.writeln(file.path);
    }
    printOnFailure(buffer.toString());
  }

  // Tests for collecting files
  group('Collecting files', () {
    test('Collect files with default patterns', () async {
      final collector = FileCollector();
      final config = Config(
        directory: testDataLibDir,
        prefix: 'example',
      );

      final files = await collector.collect(config);
      printOnFailureFiles(files);

      // a.dart and b.dart
      expect(files.length, 2);
    });

    test('Collect files with custom include patterns', () async {
      final collector = FileCollector();
      final config = Config(
          directory: testDataLibDir,
          prefix: 'example',
          includePatterns: ['**/a.dart', '**/b.dart']);

      final files = await collector.collect(config);
      printOnFailureFiles(files);

      // a.dart and b.dart
      expect(files.length, 2);
    });

    test('Collect files with custom exclude patterns', () async {
      final collector = FileCollector();
      final config = Config(
          directory: testDataLibDir,
          prefix: 'example',
          excludePatterns: ['**/a.dart']);

      final files = await collector.collect(config);
      printOnFailureFiles(files);

      // b.dart, c.g.dart, d.freezed.dart, e.part.dart
      expect(files.length, 4);
    });
  });

  group('Barrel file generation', () {
    test('Generate barrel file', () async {
      final collector = FileCollector();
      final config = Config(
        directory: testDataLibDir,
        prefix: 'example',
      );

      final files = await collector.collect(config);
      final generator = BarrelFileGenerator();

      await generator.generate(config, files);

      final barrelFile =
          File(path.join(testDataLibDir, '${config.prefix}.dart'));

      expect(await barrelFile.exists(), isTrue);

      stdout.writeln('### Generated barrel file content BEGIN ###');
      stdout.writeln(await barrelFile.readAsString());
      stdout.writeln('### Generated barrel file content END ###');
    });
  });
}
