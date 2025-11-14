# Simple Barrel Generator

A simple Dart barrel file generator tool.

## Installation

Add dependency in your `pubspec.yaml`:

```yaml
dev_dependencies:
  simple_barrel_generator: ^0.0.1
```

## Usage

```bash
dart simple_barrel_generator/main.dart <Options>
```

| Option                   | Required | Description                                         | Default                                  |
| ------------------------ | -------- | --------------------------------------------------- | ---------------------------------------- |
| -b, --base-dir           | Yes      | The root directory of source files.                 | -                                        |
| -p, --prefix             | Yes      | The prefix for the barrel file name.                | -                                        |
| -i, --include-extensions | No       | Comma-separated list of file extensions to include. | `.dart`                                  |
| -e, --exclude-extensions | No       | Comma-separated list of file extensions to exclude. | `.g.dart`, `.freezed.dart`, `.part.dart` |
| -h, --help               | No       | Show usage.                                         | -                                        |


---

## Example


### Directory Structure

Generator will create barrel files in the `lib` directories of `packages/commons`

```
packages/
  commons/
    lib/
      src/
        file1.dart
        file2.dart
      commons.dart      <-- generated barrel file
```

### Command

```bash
dart simple_barrel_generator/main.dart -b packages/commons/lib -p commons
```

`commons.dart` will be generated in `packages/commons/lib/` with the following content:


```dart
library;

export 'src/file1.dart';
export 'src/file2.dart';
```
