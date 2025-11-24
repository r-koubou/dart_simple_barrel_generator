import 'package:path/path.dart' as path;

/// Converts a path string using Windows-style backslashes to a POSIX-style path.
///
/// Replaces every `\` with `/` without performing any additional normalization,
/// resolution, or validation. This is a simple, lossless, character-level
/// substitution intended for quick interoperability.
///
/// Example:
///   r'C:\temp\file.txt' -> 'C:/temp/file.txt'
///
/// [pathName] The original path string (may already be POSIX).
/// Returns the path with all backslashes replaced by forward slashes.
String toPosixPathSeparator(String pathName) {
  return pathName.replaceAll(r'\', '/');
}

///
/// Produces a normalized absolute POSIX-style path from [pathName].
///
/// Processing pipeline:
/// 1. Convert to an absolute path.
/// 2. Normalize (resolves `.` / `..`, removes redundant separators).
/// 3. Force POSIX separators (`/`), regardless of host platform.
///
/// Use this when you need a stable, cross-platform canonical path
/// (e.g. for comparison, caching, hashing, code generation).
///
String normalizeAbsPathAsPosix(String pathName) {
  return toPosixPathSeparator(path.normalize(path.absolute(pathName)));
}
