import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

abstract class CorrectionProducer {
  late CorrectionProducerContext _context;

  ResolvedUnitResult get resolvedResult => _context.resolvedResult;

  AnalysisError? get analysisError => _context.analysisError;

  Diagnostic? get diagnostic => _context.diagnostic;

  FixKind get fixKind;

  void configure(CorrectionProducerContext context) => _context = context;

  Future<void> compute(ChangeBuilder builder);
}

abstract class DartFileCorrectionProducer extends CorrectionProducer {
  @override
  Future<void> compute(ChangeBuilder builder) async {
    await builder.addDartFileEdit(resolvedResult.path, buildFileEdit);
  }

  Future<void> buildFileEdit(DartFileEditBuilder dartFileEditBuilder);
}

class CorrectionProducerContext {
  CorrectionProducerContext._({
    required this.resolvedResult,
    this.analysisError,
    this.diagnostic,
  });

  factory CorrectionProducerContext.create({
    required ResolvedUnitResult resolvedResult,
    AnalysisError? analysisError,
    Diagnostic? diagnostic,
  }) {
    return CorrectionProducerContext._(
      resolvedResult: resolvedResult,
      analysisError: analysisError,
      diagnostic: diagnostic,
    );
  }

  /// resolvedResult
  final ResolvedUnitResult resolvedResult;

  /// error
  final AnalysisError? analysisError;

  /// diagnostic
  final Diagnostic? diagnostic;
}
