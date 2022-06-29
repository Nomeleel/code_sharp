import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
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
    int elseStatementCount = 0;
    Statement? elseStatement = node.elseStatement;
    Iterable<SyntacticEntity> childEntities = node.condition.childEntities;

    while (elseStatement is IfStatement && _conditionSimilar(childEntities, elseStatement.condition.childEntities)) {
      elseStatementCount++;
      if (elseStatementCount >= maxIfStatementCount) {
        return rule.reportLint(node);
      } else {
        childEntities = elseStatement.condition.childEntities;
        elseStatement = elseStatement.elseStatement;
      }
    }
  }

  // TODO(Nomeleel): Current simple check, todo imp.
  bool _conditionSimilar(Iterable<SyntacticEntity> a, Iterable<SyntacticEntity> b) =>
      a.first.toString() == b.first.toString();
}
