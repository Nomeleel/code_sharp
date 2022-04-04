import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/error/lint_codes.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fix_contributor_mixin.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import 'correction_map.dart';
import 'correction_producer.dart';

class LintFixContributor extends FixContributor with FixContributorMixin {
  @override
  Future<void> computeFixesForError(AnalysisError error) async {
    if (request == null) return;
    if (error.errorCode is LintCode) {
      final correctionList = lintCorrectionMap[error.errorCode.name];
      if (correctionList?.isNotEmpty ?? false) {
        final context = CorrectionProducerContext.create(
          resolvedResult: request!.result,
          analysisError: error,
          diagnostic: error,
        );

        for (final correction in correctionList!) {
          await compute(correction, context);
        }
      }
    }
  }

  Future<void> compute(CorrectionProducer producer, CorrectionProducerContext context) async {
    producer.configure(context);
    final changeBuilder = ChangeBuilder(
      session: request!.result.session,
      // TODO(Nomeleel): imp
      // workspace:
    );
    await producer.compute(changeBuilder);
    addFix(context.analysisError, producer.fixKind, changeBuilder);
  }
}
