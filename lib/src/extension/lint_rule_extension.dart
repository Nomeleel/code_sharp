// ignore_for_file: implementation_imports

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/dart/element/inheritance_manager3.dart';
import 'package:analyzer/src/dart/element/type_system.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:analyzer/src/lint/linter_visitor.dart';

extension LintRuleExtension on LintRule {
  // TODO(Nomeleel): Refine.
  List<AnalysisError> lint(ResolvedUnitResult resolvedUnit) {
    RecordingErrorListener listener = RecordingErrorListener();
    reporter = ErrorReporter(listener, resolvedUnit.unit.declaredElement!.source);
    final nodeRegistry = NodeLintRegistry(false);
    registerNodeProcessors(
      nodeRegistry,
      LinterContextImpl(
        [],
        LinterContextUnit(resolvedUnit.content, resolvedUnit.unit),
        resolvedUnit.session.declaredVariables,
        resolvedUnit.typeProvider,
        resolvedUnit.typeSystem as TypeSystemImpl,
        InheritanceManager3(),
        resolvedUnit.session.analysisContext.analysisOptions,
        null,
      ),
    );

    resolvedUnit.unit.accept(LinterVisitor(nodeRegistry));

    return listener.errors;
  }
}
