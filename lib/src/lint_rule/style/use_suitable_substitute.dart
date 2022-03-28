import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Use suitable substitute.';

const _details = r''' ''';

class UseSuitableSubstitute extends LintRule {
  UseSuitableSubstitute()
      : super(
          name: 'use_suitable_substitute',
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
    // TODO(Nomeleel): Imp
  }
}

///  extends
///  Flex-direction: Axis.horizontal -> Row
///  Flex-direction: Axis.vertical -> Column
///  Flexible-fit: FlexFit.tight => Expanded
///  Align-alignment: Alignment.center -> Center
/// 
///  same
///  Expanded(child: const SizedBox.shrink()) -> Spacer