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

bool everyArgumentInExpectedList(ArgumentList argumentList, List<String> expectedList) {
  if (argumentList.arguments.length > expectedList.length) return false;
  return argumentList.arguments.every((arg) {
    return arg is NamedExpression ? expectedList.any((property) => arg.name.label.name == property) : false;
  });
}

bool argumentHasExpected(ArgumentList argumentList, String expected) {
  return argumentList.arguments.any((arg) {
    return arg is NamedExpression ? expected == arg.name.label.name : false;
  });
}

InstanceCreationExpression? findAncestorInstanceCreationExpression(AstNode node) {
  if (node is InstanceCreationExpression) {
    return node.parent?.parent?.parent as InstanceCreationExpression?;
  }
}
