import 'package:path/path.dart' as path;

String toPosixPath(String pathName) {
  return pathName.replaceAll(r'\', '/');
}

String notmalizeAbsPathAsPosix(String pathName) {
  return toPosixPath(path.normalize(path.absolute(pathName)));
}
