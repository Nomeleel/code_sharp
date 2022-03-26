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
      final name = errorNode.constructorName.name.toString();
      final child = flutter.findChildArgument(errorNode)?.expression;
      final property = widgetPropertyMap[name]!;
      // TODO(Nomeleel): Margin
      // TODO(Nomeleel): Default value.
      final propertyExpression = flutter.findNamedArgument(errorNode, property)?.expression ?? 'Alignment.center';
      final container = findAncestorInstanceCreationExpression(errorNode);
      if (container != null) {
        final containerChild = flutter.findChildArgument(container)?.expression;
        dartFileEditBuilder.addSimpleReplacement(range.node(containerChild!), child.toString());
        // TODO(Nomeleel): Util.
        final offset = resolvedResult.lineInfo.getLocation(range.node(errorNode.parent!).offset).columnNumber;
        dartFileEditBuilder.addSimpleInsertion(
          range.node(errorNode.parent!).offset,
          '$property: $propertyExpression,\r' + '\t' * (offset ~/ 2),
        );
      }
    }
  }
}

final Map<String, String> widgetPropertyMap = {
  'Align': 'alignment',
  'Center': 'alignment',
  'Padding': 'padding',
  'Transform': 'transform',
};