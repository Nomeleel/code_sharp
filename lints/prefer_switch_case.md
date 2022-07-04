# Rule prefer_switch_case

**Group**: style\
**Maturity**: stable\
**Since**: Code Sharp v0.0.1\

[![recommended](style-recommended.svg)](https://github.com/Nomeleel/code_sharp/blob/main/lib/recommended.yaml)
[![flutter](style-flutter.svg)](https://github.com/Nomeleel/code_sharp/blob/main/lib/flutter.yaml)

## Description

Prefer switch case instead of multiple if else processes.

**BAD:**
```dart

void action(int code) {
  if (code == 0) {
    // doSomething();
  } else if (code == 1) {
    // doSomething()
  } else if (code == 2) {
    // doSomething()
  } else if (code == 3) {
    // doSomething()
  } else {
    // doSomething()
  }
}

```

**GOOD:**
```dart
void action(int code) {
  switch (code) {
    case 0:
      // doSomething();
      break;
    case 1:
      // doSomething();
      break;
    case 2:
      // doSomething();
      break;
    case 3:
      // doSomething();
      break;
    default:
    // doSomething();
  }
}
```
