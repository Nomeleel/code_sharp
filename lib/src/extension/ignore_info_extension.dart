import 'package:analyzer/src/dart/error/lint_codes.dart';
import 'package:analyzer/src/ignore_comments/ignore_info.dart';

extension IgnoreInfoExtension on IgnoreInfo {
  bool ignoredAtFile(LintCode lintCode) {
    return ignoredForFile.any((name) => name.matches(lintCode));
  }

  bool ignoredAtLine(LintCode lintCode, int line) {
    return ignoredOnLine[line]?.any((name) => name.matches(lintCode)) ?? false;
  }
}