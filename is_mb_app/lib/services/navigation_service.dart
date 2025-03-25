import 'package:flutter/material.dart';

import '../screen_layouts/master_wrapper.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {int? tabIndex}) {
    if (tabIndex != null) {
      // If navigating to one of our main tabs
      return navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MainWrapper(initialIndex: tabIndex)),
        (Route<dynamic> route) => false,
      );
    }
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }
}
