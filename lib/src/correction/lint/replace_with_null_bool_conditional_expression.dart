import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '/src/correction/correction_producer.dart';

class ReplaceWithNullBoolConditionalExpression extends DartFileCorrectionProducer {
  @override
  FixKind get fixKind => FixKind(
      'dart.fix.replace.withNullBoolConditionalExpression', 50, "Replace with null bool conditional expression.");

  @override
  Future<void> buildFileEdit(DartFileEditBuilder dartFileEditBuilder) async {
    if (node is ConditionalExpression) {
      final conditionalExp = node as ConditionalExpression;
      Expression defaultBool, expression;
      if (conditionalExp.elseExpression is BooleanLiteral) {
        defaultBool = conditionalExp.elseExpression;
        expression = conditionalExp.thenExpression;
      } else {
        defaultBool = conditionalExp.thenExpression;
        expression = conditionalExp.elseExpression;
      }
      final binaryExp = conditionalExp.condition as BinaryExpression;
      final nullCheckExp = binaryExp.leftOperand is NullLiteral ? binaryExp.rightOperand : binaryExp.leftOperand;

      dartFileEditBuilder.addSimpleReplacement(
        range.node(node),
        '${expression.toString().replaceAll('$nullCheckExp', '$nullCheckExp?')} ?? $defaultBool',
      );
    }
  }
}
