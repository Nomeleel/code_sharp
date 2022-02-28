// ignore_for_file: implementation_imports

import 'dart:io';

import 'package:analyzer/error/error.dart' as error;
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:code_sharp/src/linter_options/linter_options.dart';
import 'package:linter/src/analyzer.dart';

Future<Iterable<AnalysisError>> analysis(AnalysisDriver driver, String fileToAnalysis) async {
  final linterOptions = loadLinterOptions(driver);
  final dartLinter = DartLinter(linterOptions); // TODO(Nomeleel): Reporter imp.
  final analysisErrorInfo = await lintFiles(dartLinter, [File(fileToAnalysis)]);
  return analysisErrorInfo.expand((info) => info.errors.map(mapToPluginAnalysisError));
}

AnalysisError mapToPluginAnalysisError(error.AnalysisError error) {
  return AnalysisError(
    AnalysisErrorSeverity.INFO,
    AnalysisErrorType.LINT,
    Location(
      error.source.uri.path,
      error.offset,
      error.length,
      // TODO(Nomeleel): Compute.
      0,
      0,
    ),
    error.errorCode.message,
    error.errorCode.name,
  );
}
