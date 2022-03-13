import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/lint/config.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:linter/src/analyzer.dart';

import '/src/analysis_options/analysis_options.dart';
import '/src/extension/linter_options_extension.dart';

Map<AnalysisDriver, LinterOptions> _linterOptionsMap = {};

LinterOptions loadLinterOptions(AnalysisDriver driver) {
  if (_linterOptionsMap.containsKey(driver)) return _linterOptionsMap[driver]!;

  final linterOptions = LinterOptions();
  // TODO(Nomeleel): Full option.
  linterOptions.resourceProvider = PhysicalResourceProvider.INSTANCE;
  final analysisOptions = loadAnalysisOptions(driver);
  if (analysisOptions != null) {
    linterOptions.configure2(LintConfig.parseMap(analysisOptions), driver.analysisOptions);
  }
  _linterOptionsMap[driver] = linterOptions;

  return linterOptions;
}
