import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';

import '/src/utilities/ast_node.dart';
import '/src/utilities/flutter.dart';

const _desc = r"Use Container '{0}' property as possible.";

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
    if (!flutter.isExactWidgetTypeContainer(node.staticType)) return;

    // TODO(Nomeleel): Margin?
    final nodeChildExpression = flutter.findChildArgument(node);
    if (nodeChildExpression != null) {
      if (nodeChildExpression.staticType is InterfaceType) {
        final checker = checkerPropertyMap.keys.firstWhere(
          (isExactWidgetType) => isExactWidgetType(nodeChildExpression.staticType),
          orElse: () => null,
        );
        if (checker != null) {
          final property = checkerPropertyMap[checker];
          // The property is already set and presumably does not need to rely on repeated application of the child.
          if (argumentHasExpected(node.argumentList, property)) return;
          final reportArgs = <String>[property];
          final childExpression = nodeChildExpression.expression;
          if (childExpression is InstanceCreationExpression) {
            final childArgumentList = childExpression.argumentList;
            if (everyArgumentInExpectedList(childArgumentList, [property, 'child'])) {
              final String? propertyStr = flutter.findNamedArgument(childExpression, property)?.expression.toString();
              rule.reportLint(childExpression.constructorName, arguments: reportArgs..add(propertyStr ?? ''));
            }
          } else {
            // Only report, no fix will be provided.
            rule.reportLint(getSimpleAstNodeByExpression(childExpression), arguments: reportArgs);
          }
        }
      }
    }
  }
}

Map checkerPropertyMap = {
  flutter.isExactWidgetTypeAlign: 'alignment',
  flutter.isExactWidgetTypeCenter: 'alignment',
  flutter.isExactWidgetTypePadding: 'padding',
  flutter.isExactWidgetTypeTransform: 'transform',
};
