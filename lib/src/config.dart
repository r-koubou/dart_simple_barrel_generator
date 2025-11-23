/// A configuration class for barrel file generation.
class Config {
  /// The default directory is the current directory.
  static const String defaultPackageDirectory = '.';

  /// The default include and exclude patterns.
  /// - A pattern is supported `glob` format.
  /// - Value: `**.dart`
  static const defaultIncludes = ['**.dart'];

  /// Default exclude patterns.
  /// - A pattern is supported `glob` format.
  /// - Value: `['**.g.dart', '**.freezed.dart', '**.part.dart']`
  static const defaultExcludes = [
    '**.g.dart',
    '**.freezed.dart',
    '**.part.dart'
  ];

  /// The directory to generate the barrel file in.
  final String directory;

  /// The prefix for the barrel file name.
  final String prefix;

  /// For the include patterns.
  final List<String> includePatterns;

  /// For the exclude patterns.
  final List<String> excludePatterns;

  /// Creates a [Config] instance with the given parameters.
  /// * [directory]: The directory to generate the barrel file in.
  /// * [prefix]: The prefix for the barrel file name.
  /// * [includePatterns]: The include patterns for files to be exported.
  /// * [excludePatterns]: The exclude patterns for files to be ignored.
  /// If not provided, default values will be used.
  Config({
    required this.directory,
    required this.prefix,
    this.includePatterns = defaultIncludes,
    this.excludePatterns = defaultExcludes,
  });

  /// Creates a shallow copy of this [Config] with the given parameters replaced.
  Config copyWith({
    String? directory,
    String? barrelPrefix,
    List<String>? includePatterns,
    List<String>? excludePatterns,
  }) {
    return Config(
      directory: directory ?? this.directory,
      prefix: barrelPrefix ?? prefix,
      includePatterns: includePatterns ?? this.includePatterns,
      excludePatterns: excludePatterns ?? this.excludePatterns,
    );
  }
}
