import 'package:path/path.dart' as path;

String toPosixPathSeparator(String pathName) {
  return pathName.replaceAll(r'\', '/');
}

String normalizeAbsPathAsPosix(String pathName) {
  return toPosixPathSeparator(path.normalize(path.absolute(pathName)));
}
