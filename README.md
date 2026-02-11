# Loading Toast

A lightweight toast & loading overlay for Flutter.

![](https://github.com/user-attachments/assets/9ba6d8b3-df58-4b55-8d79-ad7bc847fe45)

## Features

- **Overlay-based toasts**: Show toast messages on top of everything using `Overlay`.
- **Flexible positioning**: Control toast position with `Alignment`, e.g. `Alignment.topCenter`, `Alignment.center`, etc.
- **No `BuildContext` required**: After initialization, you can show toasts without passing a `BuildContext`.
- **Any widget as content**: Not only text – you can show widgets like `CircularProgressIndicator`, icons, or custom widgets.

## Installing

```yaml
dependencies:
  loading_toast: ^latest
```

## Setup

If you want to use it **without context**, add `builder: LToast.init(),` to your `MaterialApp` / `CupertinoApp`:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      builder: LToast.init(),
    );
  }
}
```

## Usage

```dart
// Simple text toast (center)
LToast.showText('toast text');

// Text toast at topCenter
LToast.showText(
  'count: $_counter',
  alignment: Alignment.topCenter,
);

// Loading indicator (e.g. while waiting for a request)
LToast.showLoading(
  const CircularProgressIndicator(),
);

// Show any custom widget
LToast.show(
  const Icon(
    Icons.remove,
    color: Colors.orange,
  ),
);
```

