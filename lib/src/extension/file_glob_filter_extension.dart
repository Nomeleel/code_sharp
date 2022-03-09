import 'package:analyzer/src/lint/linter.dart';

extension FileGlobFilterExtension on FileGlobFilter {
  bool filterPath(String path) {
    return excludes.any((glob) => glob.matches(path)) && !includes.any((glob) => glob.matches(path));
  }
}