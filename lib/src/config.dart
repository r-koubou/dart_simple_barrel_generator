class Config {
  static const String defaultPackageDirectory = '.';
  static const defaultIncludes = ['**.dart'];
  static const defaultExcludes = [
    '**/*.g.dart',
    '**/*.freezed.dart',
    '**/*.part.dart'
  ];

  final String directory;
  final String prefix;
  final List<String> includePatterns;
  final List<String> excludePatterns;

  Config({
    required this.directory,
    required this.prefix,
    this.includePatterns = defaultIncludes,
    this.excludePatterns = defaultExcludes,
  });

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
