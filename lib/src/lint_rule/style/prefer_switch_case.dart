import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

import '/src/constant/lint_rule_name.dart';

const _desc = 'Prefer switch case instead of multiple if else processes.';

const _details = r'''Prefer switch case instead of multiple if else processes.

**BAD:**
```dart

void action(int code) {
  if (code == 0) {
    // doSomething();
  } else if (code == 1) {
    // doSomething()
  } else if (code == 2) {
    // doSomething()
  } else if (code == 3) {
    // doSomething()
  } else {
    // doSomething()
  }
}

```

**GOOD:**
```dart
void action(int code) {
  switch (code) {
    case 0:
      // doSomething();
      break;
    case 1:
      // doSomething();
      break;
    case 2:
      // doSomething();
      break;
    case 3:
      // doSomething();
      break;
    default:
    // doSomething();
  }
}
```
''';

const maxIfStatementCount = 2;

class PreferSwitchCase extends LintRule {
  PreferSwitchCase()
      : super(
          name: LintRuleName.preferSwitchCase,
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);

    registry.addIfStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    // 取最长的表达式, 忽略sub表达式
    if (node.parent is IfStatement) return;

    int elseStatementCount = 0;
    Statement? elseStatement = node.elseStatement;
    Expression condition = node.condition;

    while (elseStatement is IfStatement) {
      if (_conditionSimilar(condition, elseStatement.condition)) {
        elseStatementCount++;
        condition = elseStatement.condition;
        elseStatement = elseStatement.elseStatement;
      } else {
        return;
      }
    }

    if (elseStatementCount >= maxIfStatementCount) return rule.reportLint(node);
  }

  bool _conditionSimilar(Expression a, Expression b) {
    if (a.runtimeType == b.runtimeType && a.childEntities.length == 3 && b.childEntities.length == 3) {
      final aEntities = a.childEntities.toList(), bEntities = b.childEntities.toList();

      final aToken = aEntities.removeAt(1), bToken = bEntities.removeAt(1);
      if (_toStringEqual(aToken, bToken) &&
          aToken is Token &&
          (aToken.type == TokenType.EQ_EQ || aToken.type == Keyword.IS)) {
        return aEntities.any((ea) => bEntities.any(((eb) => _toStringEqual(ea, eb))));
      }
    }
    return false;
  }

  bool _toStringEqual(a, b) => '$a' == '$b';
}
