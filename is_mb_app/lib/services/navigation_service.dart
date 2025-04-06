import 'package:flutter/material.dart';

import '../screen_layouts/master_wrapper.dart';
import '../screen_layouts/mood_tips_screen.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName,
      {int? tabIndex, Map<String, dynamic>? moodEntry, bool isStack = false}) {
    if (tabIndex != null) {
      // If navigating to one of our main tabs
      return navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MainWrapper(initialIndex: tabIndex)),
        (Route<dynamic> route) => false,
      );
    }
    if (moodEntry != null) {
      return navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MoodTipScreen(moodEntry: moodEntry)),
        (Route<dynamic> route) => false,
      );
    }
    if (isStack) {
      return navigatorKey.currentState!.pushNamed(routeName);
    }
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false);
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }
}
