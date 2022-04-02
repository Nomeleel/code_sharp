import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

import '/src/constant/lint_rule_name.dart';
import '/src/utilities/flutter.dart';

const _desc = r"The argument '{0}' equal default({1}) no need set.";

const _details = r'''The argument equal default, so no need set.

**BAD:**
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.start,
  mainAxisSize: MainAxisSize.max,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[
    FlutterLogo(),
    FlutterLogo(),
  ]
)
```

**GOOD:**
```dart
Column(
  children: <Widget>[
    FlutterLogo(),
    FlutterLogo(),
  ]
)
```
''';

class ArgumentEqualDefaultNoNeedSet extends LintRule {
  ArgumentEqualDefaultNoNeedSet()
      : super(
          name: LintRuleName.argumentEqualDefaultNoNeedSet,
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(NodeLintRegistry registry, LinterContext context) {
    final visitor = _Visitor(this);

    registry.addInstanceCreationExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _checkReportLint(node.argumentList);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _checkReportLint(node.argumentList);
  }

  _checkReportLint(ArgumentList argumentList) {
    for (final item in argumentList.arguments) {
      if (item is NamedExpression && (item.element?.hasDefaultValue ?? false)) {
        if (flutter.equalIgnoreConst(item.element!.defaultValueCode, item.expression.toString().trim())) {
          rule.reportLint(item, arguments: [item.name.label, '${item.expression}']);
        }
      }
    }
  }
}
