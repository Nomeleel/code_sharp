# Rule prefer_builder_constructor_for_widget

**Group**: style\
**Maturity**: stable\
**Since**: Code Sharp v0.0.1\


## Description

Usually the builder constructor supports lazy loading.
This constructor is appropriate for multiple children views with a large (or infinite) number of children because the builder is called only for those children that are actually visible.

**BAD:**
```dart

ListView(
  children: List.generate(10000, (index) => Text('$index')),
)

```

**GOOD:**
```dart

final children = List.generate(10000, (index) => Text('$index'));
ListView.builder(
  itemCount: children.length,
  itemBuilder: (context, index) => children[index],
)

```
