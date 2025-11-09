Simple Barrel Generator
=======================

A simple Dart barrel file generator tool.

## Usage

```bash
dart simple_barrel_generator/main.dart <config_file.yaml>
```


## Yaml Configuration

- baseDir
    - The base directory where the packages are located. (default is '.').
- sourceDirectoryName
    - The name of the source directory within each package (default is 'lib').
- directories
    - List of package directories to generate barrel files for.
- includeExtensions
    - List of file extensions to include. (default: ['.dart']).
- excludeExtensions
    - List of file extensions to exclude. (default: ['.g.dart', '.freezed.dart', '.part.dart']).

### Example

```yaml
base_dir: packages
directories:
  - commons
  - ui
```
