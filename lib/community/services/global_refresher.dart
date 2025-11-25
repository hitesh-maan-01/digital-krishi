import 'package:flutter/material.dart';

class GlobalRefresher {
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  static void refresh() {
    final ctx = navKey.currentContext;
    if (ctx != null) {
      Navigator.pushReplacement(
        ctx,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ctx.widget,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }
}
