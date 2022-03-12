import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '/src/correction/correction_producer.dart';

class ReplaceContainerWithSizedBox extends CorrectionProducer {
  @override
  FixKind get fixKind => FixKind('dart.fix.replace.containerWithSizedBox2', 50, "Replace with 'SizedBox' 2");

  @override
  Future<void> compute(ChangeBuilder builder) async {
    await builder.addDartFileEdit(resolvedResult.path, (DartFileEditBuilder builder) {
      builder.addSimpleReplacement(range.error(analysisError!), 'SizedBox');
    });
  }
}
