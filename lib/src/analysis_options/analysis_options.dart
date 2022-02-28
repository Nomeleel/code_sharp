// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';
import 'package:yaml/yaml.dart';

class AnalysisOptions {
  const AnalysisOptions({required this.rules});

  factory AnalysisOptions.fromYamlMap(YamlMap? yamlMap) {
    return AnalysisOptions(rules: yamlMap?['rules'] ?? []);
  }

  final List<String> rules;
}

YamlMap? loadAnalysisOptions(AnalysisDriver driver) {
  final file = driver.analysisContext?.contextRoot.optionsFile;
  if (file?.exists ?? false) {
    return AnalysisOptionsProvider(driver.sourceFactory).getOptionsFromFile(file!)['code_sharp'];
  }
}
