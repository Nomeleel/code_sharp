import 'package:linter/src/analyzer.dart';

import 'style/argument_equal_default_no_need_set.dart';
import 'style/prefer_builder_creation_for_widget.dart';
import 'style/prefer_method_not_use_calls.dart';
import 'style/prefer_if_null_operators_with_default_bool.dart';
import 'style/prefer_switch_case.dart';
import 'style/unnecessary_import.dart';
import 'style/use_container_property_as_possible.dart';

void registerLintRules() {
  Analyzer.facade.cacheLinterVersion();
  Analyzer.facade
    ..register(UseContainerPropertyAsPossible())
    ..register(ArgumentEqualDefaultNoNeedSet())
    ..register(PreferSwitchCase())
    ..register(PreferMethodNotUseCalls())
    ..register(PreferBuilderConstructorForWidget())
    ..register(PreferIfNullOperatorsWithDefaultBool())
    ..register(UnnecessaryImport());
}
