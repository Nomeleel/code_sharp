import 'package:analyzer/error/error.dart';
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

class Ignore {
  Ignore(IgnoreInfo info, Set<String> cannotIgnore) {
    final cannotIgnoreError = cannotIgnore.map((e) => LintCode(e, e));
    bool cannotIgnoreWhere(IgnoredElement ignore) => cannotIgnoreError.any((cannot) => ignore.matches(cannot));

    ignoredForFile = List.from(info.ignoredForFile)..removeWhere(cannotIgnoreWhere);

    ignoredOnLine = Map.from(info.ignoredOnLine)..forEach((key, value) => value.removeWhere(cannotIgnoreWhere));
  }

  late final List<IgnoredElement> ignoredForFile;
  late final Map<int, List<IgnoredElement>> ignoredOnLine;

  bool ignoredAtFile(ErrorCode lintCode) {
    return ignoredForFile.any((name) => name.matches(lintCode));
  }

  bool ignoredAt(ErrorCode errorCode, int line) {
    var ignoredDiagnostics = ignoredOnLine[line];
    if (ignoredForFile.isEmpty && ignoredDiagnostics == null) {
      return false;
    }
    if (ignoredAtFile(errorCode)) {
      return true;
    }
    if (ignoredDiagnostics == null) {
      return false;
    }
    return ignoredDiagnostics.any((name) => name.matches(errorCode));
  }
}