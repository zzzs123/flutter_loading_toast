import 'dart:async';
import 'package:flutter/material.dart';

final GlobalKey<OverlayState> _toastOverlayKey = GlobalKey<OverlayState>();

Overlay _overlay(Widget? child) => Overlay(
      key: _toastOverlayKey,
      initialEntries: <OverlayEntry>[
        OverlayEntry(
          builder: (_) => child ?? const SizedBox.shrink(),
        ),
      ],
    );

const _kDefaultEdgeInset = 16.0;

class LToast {
  static TransitionBuilder init({
    TransitionBuilder? builder,
  }) {
    return (BuildContext context, Widget? child) {
      if (builder != null) {
        return builder(context, _overlay(child));
      } else {
        return _overlay(child);
      }
    };
  }

  LToast._();

  static final LToast _instance = LToast._();

  factory LToast() => _instance;

  BuildContext? get _overlayContext => _toastOverlayKey.currentContext;

  OverlayState? get _overlayState => _toastOverlayKey.currentState;

  OverlayEntry? _entry;

  Timer? _timer;

  Timer? _fadeTimer;

  void _remove() {
    _timer?.cancel();
    _fadeTimer?.cancel();
    _timer = null;
    _fadeTimer = null;
    _entry?.remove();
    _entry = null;
  }

  static void showText(
    String? text, {
    int maxLines = 1,
    Widget? icon,
    BuildContext? context,
    Alignment alignment = Alignment.center,
    Duration? duration,
    Duration? fadeDuration,
    Brightness? brightness,
  }) {
    if (text == null || text.isEmpty) return;

    final temp = _TextView(
      text: text,
      icon: icon,
      brightness: brightness,
      maxLines: maxLines,
    );

    show(
      temp,
      context: context,
      alignment: alignment,
      duration: duration,
      fadeDuration: fadeDuration,
      absorbPointer: false,
      autoRemove: true,
    );
  }

  /// if [absorbPointer] is true, blocks user interaction behind
  static void showLoading(
    Widget child, {
    BuildContext? context,
    Alignment alignment = Alignment.center,
    bool absorbPointer = true,
  }) {
    show(
      child,
      context: context,
      alignment: alignment,
      absorbPointer: absorbPointer,
      autoRemove: false,
    );
  }

  /// if [absorbPointer] is true, blocks user interaction behind
  static void show(
    Widget child, {
    BuildContext? context,
    Alignment alignment = Alignment.center,
    Duration? duration,
    Duration? fadeDuration,
    bool absorbPointer = false,
    bool autoRemove = true,
  }) {
    _instance._remove();

    final ctx = context ?? _instance._overlayContext;
    if (ctx == null || !ctx.mounted) return;

    final overlayState = _instance._overlayState;
    if (overlayState == null) return;

    /// if keyboard is displayed, change the position to center
    if (alignment.y == 1.0) {
      if (MediaQuery.of(ctx).viewInsets.bottom != 0) {
        alignment = Alignment(alignment.x, 0.0);
      }
    }

    final d = duration ?? const Duration(seconds: 2);
    final fd = fadeDuration ?? const Duration(milliseconds: 250);

    _instance._entry = OverlayEntry(
      builder: (context) => SafeArea(
        child: _ToastAnimation(
          duration: d,
          fadeDuration: fd,
          autoRemove: autoRemove,
          child: _ToastCanvas(
            alignment: alignment,
            absorbing: absorbPointer,
            child: child,
          ),
        ),
      ),
    );

    overlayState.insert(_instance._entry!);

    if (autoRemove) {
      _instance._timer = Timer(d, () {
        _instance._fadeTimer = Timer(fd, () {
          _instance._remove();
        });
      });
    }
  }

  static void hide() {
    _instance._remove();
  }
}

class _ToastCanvas extends StatelessWidget {
  const _ToastCanvas({
    required this.alignment,
    required this.child,
    required this.absorbing,
  });

  final Alignment alignment;
  final Widget child;
  final bool absorbing;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: absorbing,
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.hardEdge,
        child: Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + _kDefaultEdgeInset,
              bottom: kBottomNavigationBarHeight + _kDefaultEdgeInset,
              left: _kDefaultEdgeInset,
              right: _kDefaultEdgeInset,
            ),
            child: Align(
              alignment: alignment,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastAnimation extends StatefulWidget {
  const _ToastAnimation({
    required this.child,
    required this.duration,
    required this.fadeDuration,
    required this.autoRemove,
  });

  final Widget child;
  final Duration duration;
  final Duration fadeDuration;
  final bool autoRemove;

  @override
  State<_ToastAnimation> createState() => _ToastAnimationState();
}

class _ToastAnimationState extends State<_ToastAnimation> {
  double _opacity = 1.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    if (widget.autoRemove) {
      _timer = Timer(widget.duration, () {
        setState(() {
          _opacity = 0.0;
        });
      });
    }
  }

  @override
  void deactivate() {
    _timer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.fadeDuration,
      child: widget.child,
    );
  }
}

class _ToastFadeAnimation extends StatefulWidget {
  const _ToastFadeAnimation(
    this.child,
    this.duration,
    this.fadeDuration,
    this.autoRemove,
  );

  final Widget child;
  final Duration duration;
  final Duration fadeDuration;
  final bool autoRemove;

  @override
  _ToastFadeAnimationState createState() => _ToastFadeAnimationState();
}

class _ToastFadeAnimationState extends State<_ToastFadeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  late Animation _fadeAnimation;

  Timer? _reverseTimer;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    );

    _animationController?.forward();

    if (widget.autoRemove) {
      _reverseTimer = Timer(widget.duration, () {
        _animationController?.reverse();
        _reverseTimer?.cancel();
      });
    }

    super.initState();
  }

  @override
  void deactivate() {
    _reverseTimer?.cancel();
    _animationController?.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _reverseTimer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation as Animation<double>,
      child: widget.child,
    );
  }
}

class _TextView extends StatelessWidget {
  const _TextView({
    required this.text,
    this.icon,
    this.brightness,
    this.maxLines = 1,
  });

  final String text;
  final Widget? icon;
  final Brightness? brightness;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final bright = brightness ?? Theme.of(context).brightness;
    final contentColor = _contentColor(bright);
    final backgroundColor = _backgroundColor(bright);

    final widgets = <Widget>[
      if (icon != null)
        Padding(
          padding: EdgeInsets.only(right: 6),
          child: icon,
        ),
      Flexible(
        child: Text(
          text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: contentColor,
          ),
        ),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.5),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widgets,
        ),
      ),
    );
  }

  Color _contentColor(Brightness brightness) => switch (brightness) {
        Brightness.light => Colors.white,
        Brightness.dark => Colors.black,
      };

  Color _backgroundColor(Brightness brightness) => switch (brightness) {
        Brightness.light => Colors.black,
        Brightness.dark => Colors.white,
      };
}
