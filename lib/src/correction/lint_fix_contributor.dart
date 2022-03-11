import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/error/lint_codes.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fix_contributor_mixin.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import 'correction_producer.dart';
import 'lint/replace_container_with_sized_box.dart';

class LintFixContributor extends FixContributor with FixContributorMixin {
  @override
  Future<void> computeFixesForError(AnalysisError error) async {
    if (request == null) return;
    // TODO(Nomeleel): imp
    if (error.errorCode is LintCode) {
      if (error.errorCode.name == 'sized_box_for_whitespace') {
        final context = CorrectionProducerContext.create(
          resolvedResult: request!.result,
          analysisError: error,
          diagnostic: error,
        );

        final correctionProducer = ReplaceContainerWithSizedBox();
        await compute(correctionProducer, context);
      }
    }
  }

  Future<void> compute(CorrectionProducer producer, CorrectionProducerContext context) async {
    producer.configure(context);
    final changeBuilder = ChangeBuilder(
      session: request!.result.session,
      // workspace:
    );
    addFix(context.analysisError!, producer.fixKind, changeBuilder);
  }
}
