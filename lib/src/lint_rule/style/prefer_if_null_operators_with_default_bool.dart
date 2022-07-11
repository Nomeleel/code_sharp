/// Reference: https://github.com/dart-lang/linter/blob/master/lib/src/rules/prefer_null_aware_operators.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

import '/src/constant/lint_rule_name.dart';

const _desc = r'Prefer using if null operators with default bool value.';

const _details = r'''

Prefer using if null operators with default bool value instead of null checks in conditional
expressions.

**BAD:**
```dart

final isEmpty = a == null ? true : a.isEmpty();

```

**GOOD:**
```dart

final isEmpty = a?.isEmpty() ?? true;

```

''';

class PreferIfNullOperatorsWithDefaultBool extends LintRule {
  PreferIfNullOperatorsWithDefaultBool()
      : super(
          name: LintRuleName.preferIfNullOperatorsWithDefaultBool,
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);

    registry.addConditionalExpression(this, visitor);
    registry.addIfStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    if (node.staticType?.isDartCoreBool ?? false) {
      var condition = node.condition;
      if (condition is BinaryExpression) {
        Expression expression;
        if (condition.leftOperand is NullLiteral) {
          expression = condition.rightOperand;
        } else if (condition.rightOperand is NullLiteral) {
          expression = condition.leftOperand;
        } else {
          return;
        }

        Expression? exp;
        if (condition.operator.type == TokenType.EQ_EQ) {
          exp = node.elseExpression;
        } else if (condition.operator.type == TokenType.BANG_EQ) {
          exp = node.thenExpression;
        } else {
          return;
        }

        while (exp is PrefixedIdentifier || exp is MethodInvocation || exp is PropertyAccess) {
          if (exp is PrefixedIdentifier) {
            exp = exp.prefix;
          } else if (exp is MethodInvocation) {
            exp = exp.target;
          } else if (exp is PropertyAccess) {
            exp = exp.target;
          }
          if (exp.toString() == expression.toString()) {
            rule.reportLint(node);
            return;
          }
        }
      }
    }
  }

  @override
  void visitIfStatement(IfStatement node) {
    final nullExpList = [];
    final expList = [];

    void collect(Expression node) {
      if (node is BinaryExpression) {
        switch (node.operator.type) {
          case TokenType.BAR_BAR:
          case TokenType.AMPERSAND_AMPERSAND:
            collect(node.leftOperand);
            collect(node.rightOperand);
            break;
          case TokenType.BANG_EQ:
          case TokenType.EQ_EQ:
            if (node.leftOperand is NullLiteral) nullExpList.add(node.rightOperand);
            if (node.rightOperand is NullLiteral) nullExpList.add(node.leftOperand);
            break;
          default:
        }
      } else {
        expList.add(node);
      }
    }

    collect(node.condition);

    if (nullExpList.isNotEmpty && expList.isNotEmpty) {
      if (nullExpList.any((nullExp) => expList.any((exp) => exp.toString().startsWith(nullExp.toString())))) {
        rule.reportLint(node.condition);
      }
    }
  }
}
