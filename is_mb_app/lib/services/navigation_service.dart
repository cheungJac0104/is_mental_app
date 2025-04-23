import 'package:flutter/material.dart';

import '../screen_layouts/master_wrapper.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName,
      {int? tabIndex, bool isStack = false}) {
    if (tabIndex != null) {
      // If navigating to one of our main tabs
      return navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MainWrapper(initialIndex: tabIndex)),
        (Route<dynamic> route) => false,
      );
    }
    if (isStack) {
      return navigatorKey.currentState!.pushNamed(routeName);
    }
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false);
  }

  Future<dynamic> toScreen<T extends Widget>({
    required T screen,
    bool clearStack = true,
    Object? arguments,
  }) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return Future.value(null);

    if (clearStack) {
      return navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => screen),
        (Route<dynamic> route) => false,
      );
    } else {
      return navigator.push(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }
}
