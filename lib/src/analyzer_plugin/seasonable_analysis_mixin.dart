// ignore_for_file: implementation_imports

import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';

mixin SeasonableAnalysisMixin on ServerPlugin {
  @override
  void contentChanged(String path) {
    driverForPath(path)?.addFile(path);
  }

  @override
  Future<AnalysisSetContextRootsResult> handleAnalysisSetContextRoots(
    AnalysisSetContextRootsParams parameters,
  ) async {
    final newlyContextRoots = parameters.roots.where((context) => !driverMap.containsKey(context)).toList();

    final result = super.handleAnalysisSetContextRoots(parameters);

    newlyContextRoots.forEach(_setPriorityFilesByContextRoot);

    return result;
  }

  _setPriorityFilesByContextRoot(ContextRoot contextRoot) {
    final driver = driverMap[contextRoot] as AnalysisDriver?;
    if (driver != null) {
      driver.priorityFiles = driver.addedFiles.toList();
    }
  }

  @override
  Future<AnalysisSetPriorityFilesResult> handleAnalysisSetPriorityFiles(
    AnalysisSetPriorityFilesParams parameters,
  ) async {
    return AnalysisSetPriorityFilesResult();
  }
}
