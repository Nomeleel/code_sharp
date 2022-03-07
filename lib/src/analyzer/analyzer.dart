// ignore_for_file: implementation_imports

import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/ignore_comments/ignore_info.dart';
import 'package:analyzer/src/lint/analysis.dart';
import 'package:analyzer/src/lint/io.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/utilities/analyzer_converter.dart';

import '/src/extension/file_glob_filter_extension.dart';
import '/src/extension/ignore_info_extension.dart';
import '/src/extension/lint_rule_extension.dart';
import '/src/extension/linter_options_extension.dart';
import '/src/linter_options/linter_options.dart';

Future<Iterable<AnalysisError>> analysis2(AnalysisDriver driver, ResolvedUnitResult result) async {
  final path = result.path;
  if (driver.analysisContext?.contextRoot.isAnalyzed(path) ?? false) {
    final linterOptions = loadLinterOptions(driver);
    // TODO(Nomeleel): Filter as much as possible
    if (isDartFile(File(path)) && !linterOptions.fileFilter.filterPath(path)) {
      final ignoreInfo = IgnoreInfo.forDart(result.unit, result.content);
      return linterOptions.enabledLints.where((lint) => !ignoreInfo.ignoredAtFile(lint.lintCode)).expand((rule) {
        final errors = AnalyzerConverter().convertAnalysisErrors(
          rule.lint(result),
          lineInfo: result.lineInfo,
          options: driver.analysisOptions,
        );
        return errors.where((error) => !ignoreInfo.ignoredAt(rule.lintCode, error.location.startLine));
      });
    }
  }
  return [];
}

Future<Iterable<AnalysisError>> analysis(AnalysisDriver driver, String fileToAnalysis) async {
  final linterOptions = loadLinterOptions(driver);
  final lintDriver = LintDriver(linterOptions);
  final analysisErrorInfo = await lintDriver.analyze([File(fileToAnalysis)].where((f) => isDartFile(f)));
  return analysisErrorInfo.expand(
    (info) => AnalyzerConverter().convertAnalysisErrors(
      info.errors,
      lineInfo: info.lineInfo,
      options: driver.analysisOptions,
    ),
  );
}