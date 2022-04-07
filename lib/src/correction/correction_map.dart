import '/src/constant/lint_rule_name.dart';
import '/src/correction/correction_producer.dart';
import 'lint/remove_no_need_expression.dart';
import 'lint/replace_with_container_property.dart';

final Map<String, List<CorrectionProducer>> lintCorrectionMap = {
  LintRuleName.useContainerPropertyAsPossible: [
    ReplaceWithContainerProperty(),
  ],
  LintRuleName.argumentEqualDefaultNoNeedSet: [
    RemoveNoNeedExpression(),
  ]
};
