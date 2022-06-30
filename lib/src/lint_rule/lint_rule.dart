import 'package:linter/src/analyzer.dart';

import 'style/argument_equal_default_no_need_set.dart';
import 'style/prefer_builder_creation_for_widget.dart';
import 'style/prefer_method_not_use_calls.dart';
import 'style/prefer_switch_case.dart';
import 'style/use_container_property_as_possible.dart';

void registerLintRules() {
  Analyzer.facade.cacheLinterVersion();
  Analyzer.facade
    ..register(UseContainerPropertyAsPossible())
    ..register(ArgumentEqualDefaultNoNeedSet())
    ..register(PreferSwitchCase())
    ..register(PreferMethodNotUseCalls())
    ..register(PreferBuilderConstructorForWidget());
}
