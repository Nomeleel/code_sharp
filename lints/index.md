# Code Sharp Linter for Dart

## Lint Rules

[Using the Linter](https://dart.dev/guides/language/analysis-options#enabling-linter-rules)

## Supported Lint Rules

This list is auto-generated from our sources.

Rules are organized into familiar rule groups.

- **errors** - Possible coding errors.

- **style** - Matters of style, largely derived from the official Dart Style Guide.

- **pub** - Pub-related rules.

In addition, rules can be further distinguished by *maturity*.  Unqualified
rules are considered stable, while others may be marked **experimental**
to indicate that they are under review.  Lints that are marked as **deprecated**
should not be used and are subject to removal in future Linter releases.

Rules can be selectively enabled in the analyzer using
[analysis options](https://pub.dev/packages/analyzer)
or through an
[analysis options file](https://dart.dev/guides/language/analysis-options#the-analysis-options-file).

* **An auto-generated list enabling all options is provided [here](options/options.html).**

As some lints may contradict each other, only a subset of these will be
enabled in practice, but this list should provide a convenient jumping-off point.

Many lints are included in various predefined rulesets:

* [core](https://github.com/Nomeleel/code_sharp/blob/main/lib/core.yaml) for official "core" Dart team lint rules.
* [recommended](https://github.com/Nomeleel/code_sharp/blob/main/lib/recommended.yaml) for additional lint rules "recommended" by the Dart team.
* [flutter](https://github.com/Nomeleel/code_sharp/blob/main/lib/flutter.yaml) for rules recommended for Flutter projects (`flutter create` enables these by default).

Rules included in these rulesets are badged in the documentation below.

These rules are under active development.  Feedback is
[welcome](https://github.com/Nomeleel/code_sharp/issues)!


## Error Rules

## Style Rules

**[use_container_property_as_possible](use_container_property_as_possible.md)** - Use Container '{0}' property as possible.
[![flutter](style-flutter.svg)](https://github.com/Nomeleel/code_sharp/blob/main/lib/flutter.yaml)

**[argument_equal_default_no_need_set](argument_equal_default_no_need_set.md)** - The argument '{0}' equal default({1}) no need set.
[![flutter](style-flutter.svg)](https://github.com/Nomeleel/code_sharp/blob/main/lib/flutter.yaml)

## Pub Rules

