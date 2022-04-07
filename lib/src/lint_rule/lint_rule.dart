import 'package:linter/src/analyzer.dart';

import 'style/argument_equal_default_no_need_set.dart';
import 'style/use_container_property_as_possible.dart';

void registerLintRules() {
  Analyzer.facade.cacheLinterVersion();
  Analyzer.facade
    ..register(UseContainerPropertyAsPossible())
    ..register(ArgumentEqualDefaultNoNeedSet());
}
