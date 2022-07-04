import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../correction_producer.dart';

class SimpleDeletionCorrection extends DartFileCorrectionProducer {
  @override
  FixKind get fixKind => FixKind('dart.fix.remove.noNeedExpression', 50, 'Remove no need expression');

  @override
  Future<void> buildFileEdit(DartFileEditBuilder dartFileEditBuilder) async {
    dartFileEditBuilder.addDeletion(range.error(analysisError));
  }
}