import 'package:analyzer/src/lint/config.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:analyzer/src/lint/registry.dart';
import 'package:linter/src/analyzer.dart';

extension LinterOptionsExtension on LinterOptions {
  FileGlobFilter get fileFilter => filter as FileGlobFilter;

  // Focus on enabled lint from rules of config.
  void configure2(LintConfig config) {
    enabledLints = Registry.ruleRegistry.where(
      (LintRule rule) => config.ruleConfigs.any((rc) => rc.enables(rule.name)),
    );
    filter = FileGlobFilter(config.fileIncludes, config.fileExcludes);
  }
}