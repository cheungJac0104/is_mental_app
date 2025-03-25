import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/mood_options.dart';

class MoodService {
  Future<MoodOptions> loadMoodOptions() async {
    final String response =
        await rootBundle.loadString('assets/mood_options.json');
    final data = await json.decode(response);
    return MoodOptions.fromJson(data);
  }
}
