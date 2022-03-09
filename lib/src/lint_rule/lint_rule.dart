import 'package:linter/src/analyzer.dart';

import 'sized_box_for_whitespace.dart';

void registerLintRules() {
  Analyzer.facade.cacheLinterVersion();
  Analyzer.facade
    ..register(SizedBoxForWhitespace())
    ..register(SizedBoxForWhitespace());
}
