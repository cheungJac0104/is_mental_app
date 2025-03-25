import 'package:flutter/material.dart';
import '../partical_layouts/loading_screen.dart';
import 'tailwind.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final bool _isLoading = false;
  late DateTime _selectedDate;
  String _dailyChallenge = "Loading challenge...";
  String _encouragementPhrase = "You're awesome!";

  final List<String> _encouragementPhrases = [
    "You're doing great!",
    "Every step counts!",
    "Stay motivated!",
    "You've got this!",
    "Keep pushing forward!"
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fetchDailyChallenge();
    _fetchEncouragement();
  }

  // Mock API call for daily challenge
  Future<void> _fetchDailyChallenge() async {
    try {
      // Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _dailyChallenge = _getRandomChallenge();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dailyChallenge = "Complete a 10-minute meditation session";
        });
      }
    }
  }

  // Mock API call for encouragement
  Future<void> _fetchEncouragement() async {
    try {
      // Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _encouragementPhrase = _encouragementPhrases[
              DateTime.now().millisecondsSinceEpoch %
                  _encouragementPhrases.length];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _encouragementPhrase = "Stay positive!";
        });
      }
    }
  }

  String _getRandomChallenge() {
    final challenges = [
      "Walk 10,000 steps",
      "Drink 8 glasses of water",
      "Complete 30-min workout",
      "Practice gratitude journaling",
      "Try a new healthy recipe"
    ];
    return challenges[DateTime.now().day % challenges.length];
  }

  void _onDaySelected(DateTime date) {
    if (mounted) {
      setState(() {
        _selectedDate = date;
      });
    }

    // Add API call to fetch date-specific data here
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Wellness',
            style: TwTextStyles.heading1(context)
                .copyWith(color: TwColors.primary(context))),
        centerTitle: true,
        backgroundColor: TwColors.background(context),
        elevation: 0,
        iconTheme: IconThemeData(color: TwColors.primary(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TwSizes.p4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWeekCalendar(),
            const SizedBox(height: TwSizes.p4),
            _buildDailyChallenge(),
            const SizedBox(height: TwSizes.p4),
            _buildEncouragement(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: TwColors.background(context),
        borderRadius: BorderRadius.circular(TwSizes.p3),
        boxShadow: [
          BoxShadow(
            color: TwColors.secondary(context).withOpacity(0.1),
            blurRadius: TwSizes.p2,
            spreadRadius: 1,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: TwSizes.p3),
      child: WeekCalendarCarousel(
        selectedDate: _selectedDate,
        onDaySelected: _onDaySelected,
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return Container(
      padding: const EdgeInsets.all(TwSizes.p4),
      decoration: BoxDecoration(
        color: TwColors.secondary(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(TwSizes.p3),
        border: Border.all(color: TwColors.secondary(context).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily Challenge',
                  style: TwTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: TwColors.secondary(context),
                  )),
              IconButton(
                icon: const Icon(Icons.refresh, size: TwSizes.p5),
                color: TwColors.secondary(context),
                onPressed: _fetchDailyChallenge,
              ),
            ],
          ),
          const SizedBox(height: TwSizes.p2),
          Text(_dailyChallenge,
              style: TwTextStyles.body(context).copyWith(fontSize: 18)),
          const SizedBox(height: TwSizes.p3),
          TwButton(
            onPressed: () {},
            backgroundColor: TwColors.secondary(context),
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                vertical: TwSizes.p3, horizontal: TwSizes.p4),
            child: Text('Start Challenge',
                style:
                    TwTextStyles.body(context).copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEncouragement() {
    return Container(
      padding: const EdgeInsets.all(TwSizes.p4),
      decoration: BoxDecoration(
        color: TwColors.secondary(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(TwSizes.p3),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite,
              color: TwColors.secondary(context), size: TwSizes.p6),
          const SizedBox(width: TwSizes.p3),
          Expanded(
            child: Text(_encouragementPhrase,
                style: TwTextStyles.body(context).copyWith(
                  fontStyle: FontStyle.italic,
                  color: TwColors.secondary(context),
                )),
          ),
        ],
      ),
    );
  }
}

// Modified WeekCalendarCarousel using Tailwind styles
class WeekCalendarCarousel extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDaySelected;

  const WeekCalendarCarousel({
    super.key,
    required this.selectedDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TwSizes.p10 * 1.5,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now()
              .subtract(Duration(days: DateTime.now().weekday - 1 - index));
          final isSelected = date.day == selectedDate.day;

          return Container(
            width: TwSizes.p10,
            margin: const EdgeInsets.symmetric(horizontal: TwSizes.p2),
            decoration: BoxDecoration(
              color: isSelected
                  ? TwColors.secondary(context).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(TwSizes.p3),
              border: Border.all(
                color: isSelected
                    ? TwColors.primary(context)
                    : TwColors.secondary(context).withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: SizedBox(
              height: TwSizes.p10, // Constrain the height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(date.day.toString(),
                      style: TwTextStyles.body(context).copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? TwColors.primary(context)
                            : TwColors.secondary(context),
                        fontSize: 20,
                      )),
                  const SizedBox(height: TwSizes.p1),
                  Text(_getWeekdayAbbreviation(date.weekday)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getWeekdayAbbreviation(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}
