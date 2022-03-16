import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_sharp/src/log/log.dart';

import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/flutter_utils.dart';

const _desc = r'Use Container property as possible';

const _details = r'''Use Container property as possible.

A `Container` is combined common painting, positioning, and sizing widgets, 
so his 'child' can use its properties directly.

**BAD:**
```dart
Container(
  height: 77.0,
  width: 77.0,
  child: Center(
    child: FlutterLogo(),
  ),
)
```

**GOOD:**
```dart
Container(
  height: 77.0,
  width: 77.0,
  alignment: Alignment.center,
  child: FlutterLogo(),
)
```
''';

class UseContainerPropertyAsPossible extends LintRule {
  UseContainerPropertyAsPossible()
      : super(
          name: 'use_container_property_as_possible',
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);

    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!isExactWidgetTypeContainer(node.staticType)) {
      return;
    }

    final child = node.argumentList.arguments.where((arg) => arg is NamedExpression && arg.name.label.name == 'child');

    if (child.isNotEmpty) {
      final containerChild = child.first.staticType as InterfaceType?;
      if (containerChild != null) {
        // TODO(Nomeleel): Util.
        if ([containerChild, ...containerChild.allSupertypes].any(
          // TODO(Nomeleel): Align、Padding、etc.
          (type) => type.getDisplayString(withNullability: false) == 'Align',
        )) {
          // TODO(Nomeleel): Only child、alignment param.
          logger.error('message ${((child.first) as NamedExpression).expression.runtimeType}');

          // TODO(Nomeleel): Util.
          // rule.reportLint((((child.first) as NamedExpression).expression as InstanceCreationExpression).constructorName);
          rule.reportLint((((child.first) as NamedExpression).expression as FunctionExpressionInvocation).function);
        }
      }
    }
  }
}
