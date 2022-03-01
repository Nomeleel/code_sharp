// ignore_for_file: implementation_imports

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/lint/config.dart';
import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer/src/lint/linter.dart';
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
    linterOptions.configure2(LintConfig.parseMap(analysisOptions));
  }
  _linterOptionsMap[driver] = linterOptions;

  return linterOptions;
}

extension LinterOptionsExtension on LinterOptions {
  // Focus on enabled lint from rules of config.
  void configure2(LintConfig config) {
    enabledLints = Registry.ruleRegistry.where(
      (LintRule rule) => config.ruleConfigs.any((rc) => rc.enables(rule.name)),
    );
    filter = FileGlobFilter(config.fileIncludes, config.fileExcludes);
  }
}
