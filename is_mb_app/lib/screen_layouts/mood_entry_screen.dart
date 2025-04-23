import 'package:flutter/material.dart';
import 'package:is_mb_app/api_routes/api_service.dart';
import 'package:is_mb_app/partical_layouts/loading_screen.dart';
import 'package:provider/provider.dart';
import '../api_routes/deepseek_api.dart';
import '../models/mood_options.dart';
import '../partical_layouts/bubble_background.dart';
import '../services/mood_service.dart';
import '../services/navigation_service.dart';
import 'mood_tips_screen.dart';
import 'tailwind.dart';

class MoodEntryScreen extends StatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  MoodEntryScreenState createState() => MoodEntryScreenState();
}

class MoodEntryScreenState extends State<MoodEntryScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedMood;
  int? _selectedIntensity;
  final Set<String> _selectedKeywords = {};
  final TextEditingController _noteController = TextEditingController();
  late Future<MoodOptions> _moodOptions;
  late MoodService _moodService;
  late NavigationService _navService;
  late ApiService apiService;
  bool _isLoading = false;

  late PageController _pageController;
  int _currentPage = 0;
  final double _bubbleSize = 120;

  @override
  void initState() {
    super.initState();
    _moodService = Provider.of<MoodService>(context, listen: false);
    apiService = Provider.of<ApiService>(context, listen: false);
    _navService = Provider.of<NavigationService>(context, listen: false);
    _moodOptions = _moodService.loadMoodOptions();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MoodOptions>(
      future: _moodOptions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading options'));
        }

        final options = snapshot.data!;

        if (_isLoading) return const LoadingScreen();

        return _mainCanvas(options);
      },
    );
  }

  Widget _mainCanvas(MoodOptions? options) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood',
            style: TwTextStyles.heading1(context).copyWith(
              fontFamily: 'Pacifico',
              color: TwColors.text(context),
              fontStyle: FontStyle.italic,
            )),
        centerTitle: true,
        actions: [
          if (_currentPage == 3) // Only show on last section
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _submitEntry,
            )
        ],
      ),
      body: Stack(
        children: [
          // Bubble Background Animation
          BubbleBackground(
            bubbleCount: 20,
            maxBubbleSize: _bubbleSize,
            color: Colors.blue, // Optional custom color
          ),

          // Carousel Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: _buildSection(index, options),
              );
            },
          ),

          // Page Indicator
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.4),
                  ),
                );
              }),
            ),
          ),

          // Navigation Buttons
          if (_currentPage > 0)
            Positioned(
              left: 20,
              bottom: 20,
              child: FloatingActionButton(
                heroTag: 'fab-back',
                mini: true,
                child: const Icon(Icons.arrow_back),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ),

          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              heroTag: 'fab-forward',
              mini: true,
              child:
                  Icon(_currentPage == 3 ? Icons.check : Icons.arrow_forward),
              onPressed: () {
                if (_currentPage == 3) {
                  _submitEntry();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(int index, MoodOptions? options) {
    switch (index) {
      case 0:
        return _buildMoodSection(options!.moods);
      case 1:
        return _buildIntensitySection(options!.intensityLevels);
      case 2:
        return _buildKeywordsSection(options!.keywords);
      case 3:
        return _buildNotesSection();
      default:
        return Container();
    }
  }

  Widget _buildMoodSection(List<Mood> moods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('1. How are you feeling?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: TwColors.primary(context),
                )),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: moods.map((mood) {
            return ChoiceChip(
              label: Text(mood.displayText),
              selected: _selectedMood == mood.displayText,
              onSelected: (selected) {
                setState(() {
                  _selectedMood = selected ? mood.displayText : null;
                });
              },
              backgroundColor: TwColors.background(context),
              selectedColor: TwColors.primary(context).withOpacity(0.2),
              labelStyle: TextStyle(
                color: _selectedMood == mood.displayText
                    ? TwColors.primary(context)
                    : TwColors.text(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _selectedMood == mood.displayText
                      ? TwColors.primary(context)
                      : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIntensitySection(int maxIntensity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('2. How strong is this feeling?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: TwColors.primary(context),
                )),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(maxIntensity, (index) {
            final intensity = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _selectedIntensity = intensity),
              child: Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: _selectedIntensity == intensity
                      ? _getIntensityColor(intensity).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedIntensity == intensity
                        ? _getIntensityColor(intensity)
                        : Colors.grey.shade200,
                    width: _selectedIntensity == intensity ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emotional face icon
                    Text(
                      _getIntensityEmoji(intensity),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    // Intensity level indicator
                    Container(
                      width: 24,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getIntensityColor(intensity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Number label
                    Text(
                      intensity.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _selectedIntensity == intensity
                            ? _getIntensityColor(intensity)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mild', style: TextStyle(color: Colors.grey)),
              Text('Intense', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeywordsSection(List<String> keywords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('3. What influenced your mood today?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: TwColors.primary(context),
                )),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.map((keyword) {
            return FilterChip(
              label: Text(keyword),
              selected: _selectedKeywords.contains(keyword),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedKeywords.add(keyword);
                  } else {
                    _selectedKeywords.remove(keyword);
                  }
                });
              },
              backgroundColor: TwColors.background(context),
              selectedColor: TwColors.primary(context).withOpacity(0.2),
              labelStyle: TextStyle(
                color: _selectedKeywords.contains(keyword)
                    ? TwColors.primary(context)
                    : TwColors.text(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _selectedKeywords.contains(keyword)
                      ? TwColors.primary(context)
                      : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional Notes (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: TwColors.primary(context),
                )),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe your mood in more detail...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: TwColors.secondary(context).withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: TwColors.primary(context),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getIntensityColor(int intensity) {
    final colors = [
      Colors.green.shade300,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.orange.shade600,
      Colors.red.shade600,
    ];
    return colors[intensity - 1];
  }

  String _getIntensityEmoji(int intensity) {
    switch (intensity) {
      case 1:
        return '😐'; // Neutral
      case 2:
        return '🙂'; // Slight
      case 3:
        return '😊'; // Moderate
      case 4:
        return '😄'; // Strong
      case 5:
        return '🤩'; // Extreme
      default:
        return '😶'; // Default
    }
  }

  void _submitEntry() async {
    setState(() {
      _isLoading = true;
    });
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your mood')),
      );
      return;
    }

    // Process the mood entry
    final moodEntry = {
      'mood': _selectedMood,
      'intensity': _selectedIntensity,
      'keywords': _selectedKeywords.toList(),
      'notes': _noteController.text,
      'timestamp': DateTime.now(),
    };

    final api = DeepSeekApi();

    try {
      final result = await api.generateMoodTip(
        mood: _selectedMood ?? '',
        intensity: _selectedIntensity ?? 1,
        keywords: _selectedKeywords.toList(),
        notes: _noteController.text,
      );

      debugPrint('Generated Tip: ${result['tip']}');
      debugPrint('Usage: ${result['usage']}');
      moodEntry['tip'] = result['tip'];
      moodEntry['usage'] = result['usage'];

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _navService.toScreen(screen: MoodTipScreen(moodEntry: moodEntry));
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
