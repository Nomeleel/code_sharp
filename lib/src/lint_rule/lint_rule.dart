import 'package:linter/src/analyzer.dart';

import 'sized_box_for_whitespace.dart';
import 'style/use_container_property_as_possible.dart';

void registerLintRules() {
  Analyzer.facade.cacheLinterVersion();
  Analyzer.facade
    ..register(SizedBoxForWhitespace())
    ..register(UseContainerPropertyAsPossible());
}
