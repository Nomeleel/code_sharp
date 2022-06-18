# Rule argument_equal_default_no_need_set

**Group**: style\
**Maturity**: stable\
**Since**: Code Sharp v0.0.1\

[![flutter](style-flutter.svg)](https://github.com/Nomeleel/code_sharp/blob/main/lib/flutter.yaml)

## Description

The argument equal default, so no need set.

**BAD:**
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.start,
  mainAxisSize: MainAxisSize.max,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[
    FlutterLogo(),
    FlutterLogo(),
  ]
)
```

**GOOD:**
```dart
Column(
  children: <Widget>[
    FlutterLogo(),
    FlutterLogo(),
  ]
)
```
