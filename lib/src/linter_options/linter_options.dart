// ignore_for_file: implementation_imports

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/lint/config.dart';
import 'package:code_sharp/src/analysis_options/analysis_options.dart';
import 'package:linter/src/analyzer.dart';

Map<AnalysisDriver, LinterOptions> _linterOptionsMap = {};

LinterOptions loadLinterOptions(AnalysisDriver driver) {
  if (_linterOptionsMap.containsKey(driver)) return _linterOptionsMap[driver]!;

  final linterOptions = LinterOptions();
  // TODO(Nomeleel): Full option.
  linterOptions.resourceProvider = PhysicalResourceProvider.INSTANCE;
  final analysisOptions = loadAnalysisOptions(driver);
  if (analysisOptions != null) {
    // TODO(Nomeleel): Modify enabledLints, rules node as enabled lint list.
    linterOptions.configure(LintConfig.parseMap(analysisOptions));
  }
  _linterOptionsMap[driver] = linterOptions;

  return linterOptions;
}
