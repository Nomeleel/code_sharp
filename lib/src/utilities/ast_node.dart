import 'package:analyzer/dart/ast/ast.dart';

/// Return important ast node of [expression].
AstNode getSimpleAstNodeByExpression(Expression expression) {
  /*
  switch (expression.runtimeType) {
    case InstanceCreationExpression:
      return (expression as InstanceCreationExpression).constructorName;
    case FunctionExpressionInvocation:
      return (expression as FunctionExpressionInvocation).function;
    case SimpleIdentifier:
    default:
      return expression;
  }
  */

  if (expression is InstanceCreationExpression) {
    return expression.constructorName;
  } else if (expression is FunctionExpressionInvocation) {
    return expression.function;
  } else {
    return expression;
  }
}
