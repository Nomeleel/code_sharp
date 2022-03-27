import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/lint/config.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:analyzer/src/lint/registry.dart';
import 'package:linter/src/analyzer.dart';

import '/src/extension/file_glob_filter_extension.dart';

extension LinterOptionsExtension on LinterOptions {
  FileGlobFilter? get fileFilter => filter as FileGlobFilter?;

  bool filterPath(String path) => fileFilter?.filterPath(path) ?? false;

  /// Focus on enabled lint from rules of config.
  /// [config]: Focus on code_sharp node.
  /// [analysisOptions]: Focus on other(analyzer、etc.) node.
  void configure2(LintConfig config, AnalysisOptions analysisOptions) {
    enabledLints = _applyAnalyzerErrorsIgnore(
      analysisOptions,
      Registry.ruleRegistry.where((LintRule rule) => config.ruleConfigs.any((rc) => rc.enables(rule.name))),
    );
    filter = FileGlobFilter(config.fileIncludes, config.fileExcludes);
  }

  Iterable<LintRule> _applyAnalyzerErrorsIgnore(AnalysisOptions analysisOptions, Iterable<LintRule> original) {
    final ignore = analysisOptions.errorProcessors.where(
      (processor) => processor.severity == null || processor.severity == ErrorSeverity.NONE,
    );

    return ignore.isEmpty
        ? original
        : original.where((rule) => !ignore.any((processor) => processor.code == rule.name));
  }
}
