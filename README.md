# Loading Toast


## Installing

```yaml
dependencies:
  loading_toast: ^latest
```

## How to use

if you want to use without context, should add `builder: LToast.init(),` in your `MaterialApp`/`CupertinoApp`:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      builder: LToast.init(),
    );
  }
}
```

Then, enjoy yourself:

```dart
                LToast.showText('toast text');

                LToast.showText(
                  'count: $_counter',
                  alignment: Alignment.topCenter,
                );

                LToast.showLoading(
                  const CircularProgressIndicator(),
                );

                LToast.show(
                  const Icon(
                          Icons.remove,
                          color: Colors.orange,
                        ),
                );


```

