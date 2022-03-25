import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

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
          name: 'argument_equal_default_no_need_set',
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
        // TODO(Nomeleel): const  
        if (item.element!.defaultValueCode == item.expression.toString().trim()) {
          // TODO(Nomeleel): arguments  
          rule.reportLint(item, arguments: ['remove---']);
        }
      }
    }
  }
}