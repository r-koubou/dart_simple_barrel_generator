# Simple Barrel Generator

A simple Dart barrel file generator tool.

## Installation

Add dependency in your `pubspec.yaml`:

```yaml
dependencies:
  simple_barrel_generator: ^0.0.1
```

## Usage

```bash
dart simple_barrel_generator/main.dart <config_file.yaml>
```

## Yaml Configuration

- baseDir
  - The base directory where the packages are located. (default is `. (current directory)`).
- sourceDirectoryName
  - The name of the source directory within each package (default is `lib`).
- directories
  - List of package directories to generate barrel files for.
- includeExtensions
  - List of file extensions to include. (default:`.dart`).
- excludeExtensions
  - List of file extensions to exclude. (default: `[.g.dart. freezed.dart, .part.dart]`).

---

## Example

```yaml
base_dir: packages
directories:
  - commons
  - ui
```

### Directory Structure

Generator will create barrel files in the `lib` directories of `packages/commons` and `packages/ui`.

```
packages/
  commons/
    lib/
      src/
        file1.dart
        file2.dart
      commons.dart      <-- generated barrel file
```

commons.dart:

```dart
export 'src/file1.dart';
export 'src/file2.dart';
```
