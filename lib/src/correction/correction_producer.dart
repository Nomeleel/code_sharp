import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/ast/utilities.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:code_sharp/src/log/log.dart';

abstract class CorrectionProducer {
  late CorrectionProducerContext _context;

  ResolvedUnitResult get resolvedResult => _context.resolvedResult;

  AnalysisError get analysisError => _context.analysisError;

  Diagnostic? get diagnostic => _context.diagnostic;

  AstNode get node => _context.node;

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
    required this.analysisError,
    this.diagnostic,
    required this.node,
  });

  factory CorrectionProducerContext.create({
    required ResolvedUnitResult resolvedResult,
    required AnalysisError analysisError,
    Diagnostic? diagnostic,
  }) {
    final errorEnd = analysisError.offset + analysisError.length;
    final node = NodeLocator(analysisError.offset, errorEnd).searchWithin(resolvedResult.unit) ?? resolvedResult.unit;

    return CorrectionProducerContext._(
      resolvedResult: resolvedResult,
      analysisError: analysisError,
      diagnostic: diagnostic,
      node: node,
    );
  }

  /// resolvedResult
  final ResolvedUnitResult resolvedResult;

  /// error
  final AnalysisError analysisError;

  /// diagnostic
  final Diagnostic? diagnostic;

  /// node
  final AstNode node;
}
