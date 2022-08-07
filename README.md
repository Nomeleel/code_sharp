# Code sharp

Custom lint for dart base on [linter](https://github.com/dart-lang/linter), make the code more sharp. 

## Custom Lint for Dart

Linter provides a lot of lint rules, which can meet the needs of most applications. However, at present, this system is relatively closed in the Dart [SDK](https://dart.dev/tools/sdk), and lint rules cannot be customized yet. For details, see this [issue](https://github.com/dart-lang/linter/issues/697).

Fortunately, dart sdk provides [analyzer plugin](https://github.com/dart-lang/sdk/tree/main/pkg/analyzer_plugin) that can indirectly extend custom lint rules in this way. Code Sharp came into being.

## Installing

1. Add to package's pubspec.yaml file:

```yaml

# by git
dev_dependencies:
  code_sharp:
    git: git@github.com:Nomeleel/code_sharp.git

# by pub.dev/packages
dev_dependencies:
  code_sharp: any

```

2. Add configuration to analysis_options.yaml

```yaml

analyzer:
  plugins:
    - code_sharp

code_sharp:
  rules:
    - use_container_property_as_possible
    - argument_equal_default_no_need_set

```
## Usage

The usage is similar to [linter usage](https://github.com/dart-lang/linter#usage). The difference is that the configuration node is replaced linter to ***code_sharp***. 

```yaml

code_sharp:
  rules:
    - use_container_property_as_possible
    - argument_equal_default_no_need_set

```

Other configuration node Code Sharp have also been implemented. More configuration nodes can be viewed in [analysis options](https://dart.dev/guides/language/analysis-options#the-analysis-options-file)

<!-- example -->

## Screenshot

![code_sharp_1](https://raw.githubusercontent.com/Nomeleel/Assets/master/code_sharp/markdown/code_sharp_1.gif)