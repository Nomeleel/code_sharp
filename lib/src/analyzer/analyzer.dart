// ignore_for_file: implementation_imports

import 'dart:io';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:code_sharp/src/lint_rule/sized_box_for_whitespace.dart';

import 'package:linter/src/analyzer.dart';
import 'package:analyzer/error/error.dart' as error;

Future<Iterable<AnalysisError>> analysis(List<File> filesToAnalysis) async {
  final linterOptions = LinterOptions();
  // TODO(Nomeleel): Full option.
  linterOptions.enabledLints = [SizedBoxForWhitespace()];
  linterOptions.resourceProvider = PhysicalResourceProvider.INSTANCE;

  final dartLinter = DartLinter(linterOptions); // TODO(Nomeleel): Reporter imp.
  final analysisErrorInfo = await lintFiles(dartLinter, filesToAnalysis);
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
