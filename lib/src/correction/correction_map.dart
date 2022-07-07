import '/src/constant/lint_rule_name.dart';
import '/src/correction/correction_producer.dart';
import 'common/simple_deletion_correction.dart';
import 'lint/remove_no_need_argument_expression.dart';
import 'lint/replace_with_container_property.dart';
import 'lint/replace_with_null_bool_conditional_expression.dart';

final Map<String, List<CorrectionProducer>> lintCorrectionMap = {
  LintRuleName.useContainerPropertyAsPossible: [
    ReplaceWithContainerProperty(),
  ],
  LintRuleName.argumentEqualDefaultNoNeedSet: [
    RemoveNoNeedArgumentExpression(),
  ],
  LintRuleName.preferMethodNotUseCalls: [
    SimpleDeletionCorrection(),
  ],
  LintRuleName.preferIfNullOperatorsWithDefaultBool: [
    ReplaceWithNullBoolConditionalExpression(),
  ]
};
