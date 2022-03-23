import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '/src/correction/correction_producer.dart';
import '/src/utilities/ast_node.dart';
import '/src/utilities/flutter.dart';

class ReplaceWithContainerProperty extends DartFileCorrectionProducer {
  @override
  FixKind get fixKind => FixKind('dart.fix.replace.withContainerProperty', 50, "Replace with 'Container' property");

  @override
  Future<void> buildFileEdit(DartFileEditBuilder dartFileEditBuilder) async {
    final errorNode = flutter.identifyNewExpression(node);
    if (errorNode is InstanceCreationExpression) {
      final name = errorNode.constructorName.name;
      final child = flutter.findChildArgument(errorNode)?.expression;
      // TODO(Nomeleel): Margin
      final propert = flutter.findNamedArgument(errorNode, 'alignment')?.expression;
      final container = findAncestorInstanceCreationExpression(errorNode);
      if (container != null) {
        final containerChild = flutter.findChildArgument(container)?.expression;
        dartFileEditBuilder.addSimpleReplacement(range.node(containerChild!), child.toString());
        final offset = resolvedResult.lineInfo.getLocation(range.node(errorNode.parent!).offset).columnNumber;
        dartFileEditBuilder.addSimpleInsertion(
          range.node(errorNode.parent!).offset,
          'alignment: $propert,\r' + '\t' * (offset ~/ 2),
        );
      }
    }
  }
}
