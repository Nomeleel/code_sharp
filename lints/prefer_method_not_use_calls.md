# Rule prefer_method_not_use_calls

**Group**: style\
**Maturity**: stable\
**Since**: Code Sharp v0.0.1\

[![recommended](style-recommended.svg)](https://github.com/Nomeleel/code_sharp/blob/main/lib/recommended.yaml)
[![flutter](style-flutter.svg)](https://github.com/Nomeleel/code_sharp/blob/main/lib/flutter.yaml)

## Description

Prefer method direct calls instead of call calls.

**BAD:**
```dart

void fun() {}

void doSomething() {
  fun.call();
}

```

**GOOD:**
```dart

void fun() {}

void doSomething({VoidCallback? callback}) {
  fun();
  callback?.call();
}

```
