import 'package:flutter/material.dart';
import 'package:is_mb_app/screen_layouts/mood_share_screen.dart';
import 'package:is_mb_app/services/navigation_service.dart';
import 'package:provider/provider.dart';

import '../api_routes/api_service.dart';
import '../partical_layouts/loading_screen.dart';

class MoodTipScreen extends StatefulWidget {
  final Map<String, dynamic> moodEntry;

  const MoodTipScreen({super.key, required this.moodEntry});

  @override
  MoodTipScreenState createState() => MoodTipScreenState();
}

class MoodTipScreenState extends State<MoodTipScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;
  String _displayText = "";
  final TextEditingController _feedbackController = TextEditingController();
  int _userRating = 0;
  late ApiService apiService;
  late NavigationService navService;

  // State management variables
  bool _isLoading = true;
  dynamic _moodRecordResponse;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false);
    navService = Provider.of<NavigationService>(context, listen: false);
    _setupAnimation();
    _loadData();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.moodEntry['tip'].length * 100),
      vsync: this,
    );

    _textAnimation = IntTween(
      begin: 0,
      end: widget.moodEntry['tip'].length,
    ).animate(_controller)
      ..addListener(() {
        setState(() {
          _displayText =
              widget.moodEntry['tip'].substring(0, _textAnimation.value);
        });
      });

    _controller.forward();
  }

  Future<void> _sendFeedback(Map<String, dynamic> feedbackData) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final rtn = await apiService.updateFeedback(feedbackData);

      apiService.responseBodyParse(rtn);

      if (mounted) {
        navService.toScreen(screen: MoodShareScreen(moodEntry: feedbackData));
      }
    } catch (e) {
      debugPrint("");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final response = await apiService.createMoodRecord(widget.moodEntry);

      setState(() {
        _moodRecordResponse = apiService.getResBodyJson(response);
        _moodRecordResponse['mood'] = widget.moodEntry['mood'];
        _moodRecordResponse['intensity'] = widget.moodEntry['intensity'];
        _moodRecordResponse['tip'] = widget.moodEntry['tip'];
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  void _handleRefresh() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _mainCanvas(context);
  }

  Widget _mainCanvas(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Your Mood Tip"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.indigo[800],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mood Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getMoodColor(widget.moodEntry['mood'])
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getMoodIcon(widget.moodEntry['mood']),
                            color: _getMoodColor(widget.moodEntry['mood']),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.moodEntry['mood'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Animated Tip Text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _displayText,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.indigo[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ... Rest of the UI remains the same
              const SizedBox(height: 32),
              Text(
                "How helpful was this tip?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _userRating ? Icons.star : Icons.star_border,
                      color: Colors.amber[600],
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _userRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Optional feedback...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  _moodRecordResponse['feedback'] = _userRating;
                  _moodRecordResponse['feedbackText'] =
                      _feedbackController.text;

                  //debugPrint(_moodRecordResponse.toString());
                  await _sendFeedback(_moodRecordResponse);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Submit Feedback",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'anxious':
        return Colors.orange;
      case 'excited':
        return Colors.purple;
      default:
        return Colors.indigo;
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      case 'anxious':
        return Icons.sentiment_dissatisfied;
      case 'excited':
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
