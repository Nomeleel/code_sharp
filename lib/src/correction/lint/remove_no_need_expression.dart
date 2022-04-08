import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '/src/correction/correction_producer.dart';

class RemoveNoNeedExpression extends DartFileCorrectionProducer {
  @override
  FixKind get fixKind => FixKind('dart.fix.remove.noNeedExpression', 50, "Remove no need expression");

  @override
  Future<void> buildFileEdit(DartFileEditBuilder dartFileEditBuilder) async {
    if (node is NamedExpression) {
      final parent = node.parent;
      if (parent is ArgumentList) {
        final index = parent.arguments.indexWhere((e) => e.offset == analysisError.offset);
        dartFileEditBuilder.addDeletion(range.argumentRange(parent, index, index, true));
      }
    }
  }
}
