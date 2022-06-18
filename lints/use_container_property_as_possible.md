# Rule use_container_property_as_possible

**Group**: style\
**Maturity**: stable\
**Since**: Code Sharp v0.0.1\

[![flutter](style-flutter.svg)](https://github.com/Nomeleel/code_sharp/blob/main/lib/flutter.yaml)

## Description

Use Container property as possible.

A `Container` is combined common painting, positioning, and sizing widgets, 
so his 'child' can use its properties directly.

**BAD:**
```dart
Container(
  height: 77.0,
  width: 77.0,
  child: Center(
    child: FlutterLogo(),
  ),
)
```

**GOOD:**
```dart
Container(
  height: 77.0,
  width: 77.0,
  alignment: Alignment.center,
  child: FlutterLogo(),
)
```
