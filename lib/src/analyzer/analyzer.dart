import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/ignore_comments/ignore_info.dart';
import 'package:analyzer/src/lint/analysis.dart';
import 'package:analyzer/src/lint/io.dart';

import '/src/extension/file_glob_filter_extension.dart';
import '/src/extension/ignore_info_extension.dart';
import '/src/extension/lint_rule_extension.dart';
import '/src/extension/linter_options_extension.dart';
import '/src/linter_options/linter_options.dart';

Future<Iterable<AnalysisError>> analysis(AnalysisDriver driver, ResolvedUnitResult result) async {
  final path = result.path;
  if (driver.analysisContext?.contextRoot.isAnalyzed(path) ?? false) {
    final linterOptions = loadLinterOptions(driver);
    // TODO(Nomeleel): Filter as much as possible
    if (isDartFile(File(path)) && !linterOptions.fileFilter.filterPath(path)) {
      final ignore = Ignore(
        IgnoreInfo.forDart(result.unit, result.content),
        (driver.analysisOptions as AnalysisOptionsImpl).unignorableNames,
      );
      return linterOptions.enabledLints
          .where((lint) => !ignore.ignoredAtFile(lint.lintCode))
          .expand((rule) => rule.lint(result).where(
                (error) => !ignore.ignoredAt(
                  rule.lintCode,
                  result.lineInfo.getLocation(error.offset).lineNumber,
                ),
              ));
    }
  }
  return [];
}

Future<Iterable<AnalysisError>> analysis2(AnalysisDriver driver, String fileToAnalysis) async {
  final linterOptions = loadLinterOptions(driver);
  final lintDriver = LintDriver(linterOptions);
  final analysisErrorInfo = await lintDriver.analyze([File(fileToAnalysis)].where((f) => isDartFile(f)));
  return analysisErrorInfo.expand((info) => info.errors);
}