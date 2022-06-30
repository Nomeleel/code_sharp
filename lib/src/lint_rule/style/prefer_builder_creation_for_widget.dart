import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';

import '../../utilities/flutter.dart';
import '/src/constant/lint_rule_name.dart';

const _desc = r'Prefer use {0}.builder constructor.';

const _details = r'''

Usually the builder constructor supports lazy loading.
This constructor is appropriate for multiple children views with a large (or infinite) number of children because the builder is called only for those children that are actually visible.

**BAD:**
```dart

ListView(
  children: List.generate(10000, (index) => Text('$index')),
)

```

**GOOD:**
```dart

final children = List.generate(10000, (index) => Text('$index'));
ListView.builder(
  itemCount: children.length,
  itemBuilder: (context, index) => children[index],
)

```

''';

class PreferBuilderConstructorForWidget extends LintRule {
  PreferBuilderConstructorForWidget()
      : super(
          name: LintRuleName.preferBuilderConstructorForWidget,
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
    if (flutter.isWidgetCreation(node) && node.constructorName.name == null) {
      final widget = node.staticType!.element as ClassElement;
      if (widget.constructors.any((element) => element.name == 'builder')) {
        rule.reportLint(node.constructorName, arguments: [node.constructorName]);
      }
    }
  }
}
