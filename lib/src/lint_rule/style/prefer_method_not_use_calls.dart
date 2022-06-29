import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';

import '/src/constant/lint_rule_name.dart';

const _desc = 'Prefer method direct calls instead of call calls.';

const _details = r'''Prefer method direct calls instead of call calls.

**BAD:**
```dart

void fun() {}

void doSomething() {
  fun.call();
}

```

**GOOD:**
```dart

void fun() {}

void doSomething({VoidCallback? callback}) {
  fun();
  callback?.call();
}

```
''';

class PreferMethodNotUseCalls extends LintRule {
  PreferMethodNotUseCalls()
      : super(
          name: LintRuleName.preferMethodNotUseCalls,
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);

    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target?.staticType is FunctionType && node.function.toString() == 'call' && !node.isNullAware) {
      rule.reportLint(node.function);
    }
  }
}
