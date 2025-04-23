import 'package:flutter/material.dart';
import 'package:is_mb_app/partical_layouts/loading_screen.dart';
import 'package:provider/provider.dart';

import '../api_routes/api_service.dart';
import '../services/auth_service.dart';

class StatScreen extends StatelessWidget {
  const StatScreen({super.key});

  Future<Map<String, dynamic>> _loadAnalyticsData(BuildContext context) async {
    final userId =
        Provider.of<AuthService>(context, listen: false).userIdGetter();
    final apiService = Provider.of<ApiService>(context, listen: false);
    final alyData = await apiService.getUserAnalytics(userId, userId);
    final senAlyData = await apiService.getSentimentAnalysis(userId, userId);

    return {
      'userAnalytics': apiService.getResBodyJson(alyData)['data'],
      'sentimentData': apiService.getResBodyJson(senAlyData)['data'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _loadAnalyticsData(context),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          // Access data using the map keys
          final userAnalytics = snapshot.data!['userAnalytics'];
          final sentimentData = snapshot.data!['sentimentData'];

          return CustomScrollView(
            slivers: [
              // --- SliverAppBar with Rounded Bottom ---
              SliverAppBar(
                expandedHeight: 200.0,
                pinned: true,
                elevation: 0,
                shadowColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    userAnalytics['user']['username'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade400],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // --- Stats Overview Cards ---
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildListDelegate([
                    _StatCard(
                      icon: Icons.flag,
                      title: 'Challenges Completed',
                      value: userAnalytics['metrics']['challenges_completed'],
                      color: Colors.green,
                    ),
                    _StatCard(
                      icon: Icons.thumb_up,
                      title: 'Social Engagement',
                      value: userAnalytics['metrics']['social_engagement'],
                      color: Colors.orange,
                    ),
                    _StatCard(
                      icon: Icons.group,
                      title: 'Journal Collabs',
                      value: userAnalytics['metrics']['journal_collaboration'],
                      color: Colors.purple,
                    ),
                    _StatCard(
                      icon: Icons.star,
                      title: 'Engagement Score',
                      value: userAnalytics['metrics']['engagement_score']
                          .toDouble(),
                      color: Colors.blue,
                    ),
                  ]),
                ),
              ),

              // --- Sentiment Analysis Section ---
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sentiment Analysis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                _getSentimentIcon(
                                    sentimentData['average_sentiment']
                                        .toDouble()),
                                color: _getSentimentColor(
                                    sentimentData['average_sentiment']
                                        .toDouble()),
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Average: ${sentimentData['average_sentiment'].toDouble()}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Trend: ${sentimentData['trend']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper: Get sentiment icon based on score (-1 to 1)
  IconData _getSentimentIcon(double score) {
    if (score > 0.3) return Icons.sentiment_very_satisfied;
    if (score < -0.3) return Icons.sentiment_very_dissatisfied;
    return Icons.sentiment_neutral;
  }

  // Helper: Get sentiment color
  Color _getSentimentColor(double score) {
    if (score > 0.3) return Colors.green;
    if (score < -0.3) return Colors.red;
    return Colors.amber;
  }
}

// --- Reusable Stat Card Widget ---
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final dynamic value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
