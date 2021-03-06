// Same as the official provided diagnostic, this lint will be removed.
// https://dart.dev/tools/diagnostic-messages?utm_source=dartdev&utm_medium=redir&utm_id=diagcode&utm_content=unnecessary_import#unnecessary_import
// https://github.com/dart-lang/sdk/blob/main/pkg/analyzer/lib/src/error/imports_verifier.dart#L688

// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

import '/src/constant/lint_rule_name.dart';

const _desc = r'Unnecessary import';

const _details = r'''



**BAD:**
```dart

```

**GOOD:**
```dart

```

''';

class UnnecessaryImport extends LintRule {
  UnnecessaryImport()
      : super(
          name: LintRuleName.unnecessaryImport,
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  LintCode get lintCode => LintCode(name, description);

  @override
  void registerNodeProcessors(NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);

    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // ignore: todo
    // TODO(Nomeleel): show hide etc. should ignore?
    final importList = node.directives.whereType<ImportDirective>();
    importList.forEach((element) {
      element.element?.importedLibrary?.exports.forEach((element) {
        final path = element.exportedLibrary?.source.uri.path;
        if (path?.isNotEmpty ?? false) {
          importList.forEach((e) {
            if (e.element?.importedLibrary?.source.uri.path == path) {
              rule.reportLint(e);
            }
          });
        }
      });
    });
  }
}
