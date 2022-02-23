// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:analyzer/dart/analysis/context_builder.dart';
import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/dart/analysis/driver_based_analysis_context.dart';
import 'package:analyzer_plugin/plugin/fix_mixin.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:code_sharp/src/fix/dart_fix_contributor.dart';

class AnalyzerPlugin extends ServerPlugin with FixesMixin, DartFixesMixin {
  @override
  String get contactInfo => 'https://github.com/Nomeleel/code_sharp/issues';

  @override
  List<String> get fileGlobsToAnalyze => const ['*.dart'];

  @override
  String get name => 'Code Sharp';

  @override
  String get version => '0.0.1';

  AnalyzerPlugin(ResourceProvider provider) : super(provider);

  @override
  AnalysisDriverGeneric createAnalysisDriver(ContextRoot contextRoot) {
    final locator = ContextLocator(resourceProvider: resourceProvider).locateRoots(
      includedPaths: [contextRoot.root],
      excludedPaths: contextRoot.exclude,
      optionsFile: contextRoot.optionsFile,
    );

    if (locator.isEmpty) {
      final error = StateError('Unexpected empty context');
      channel.sendNotification(PluginErrorParams(
        true,
        error.message,
        error.stackTrace.toString(),
      ).toNotification());

      throw error;
    }

    final builder = ContextBuilder(resourceProvider: resourceProvider);
    final context = builder.createContext(contextRoot: locator.first) as DriverBasedAnalysisContext;

    final driver = context.driver;

    runZonedGuarded(
      () => _listenDriverResults(driver),
      (e, stackTrace) => channel.sendNotification(
        PluginErrorParams(false, e.toString(), stackTrace.toString()).toNotification(),
      ),
    );

    return driver;
  }

  _listenDriverResults(AnalysisDriver driver) {
    driver.results.listen((result) {
      if (result is ResolvedUnitResult) {
        try {
          final errors = <AnalysisError>[];
          if (driver.analysisContext?.contextRoot.isAnalyzed(result.path) ?? false) {
            errors.addAll(_analysis());
          }
          channel.sendNotification(AnalysisErrorsParams(result.path, errors).toNotification());
        } catch (e, stackTrace) {
          channel.sendNotification(PluginErrorParams(false, e.toString(), stackTrace.toString()).toNotification());
        }
      }
    });
  }

  List<AnalysisError> _analysis() {
    // TODO(Nomeleel): imp
    return [];
  }

  @override
  Future<ResolvedUnitResult> getResolvedUnitResult(String path) async {
    final result = await super.getResolvedUnitResult(path);
    // TODO(Nomeleel): imp
    result.errors.addAll([]);
    return result;
  }

  @override
  List<FixContributor> getFixContributors(String path) => [DartFixContributor()];
}
