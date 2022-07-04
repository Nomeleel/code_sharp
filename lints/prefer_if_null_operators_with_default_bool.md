# Rule prefer_if_null_operators_with_default_bool

**Group**: style\
**Maturity**: stable\
**Since**: Code Sharp v0.0.1\

[![recommended](style-recommended.svg)](https://github.com/Nomeleel/code_sharp/blob/main/lib/recommended.yaml)
[![flutter](style-flutter.svg)](https://github.com/Nomeleel/code_sharp/blob/main/lib/flutter.yaml)

## Description

Prefer using if null operators with default bool value instead of null checks in conditional
expressions.

**BAD:**
```dart

final isEmpty = a == null ? true : a.isEmpty();

```

**GOOD:**
```dart

final isEmpty = a?.isEmpty() ?? true;

```
