import 'package:flutter/material.dart';
import 'package:is_mb_app/partical_layouts/wave_background.dart';

import 'tailwind.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  CommunityScreenState createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen> {
  bool _isChallengeJoined = false;
  final List<bool> _likedPosts = List.generate(5, (index) => false);

  @override
  Widget build(BuildContext context) {
    return _mainCanvas();
  }

  Widget _mainCanvas() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Community',
              style: TwTextStyles.heading1(context).copyWith(
                fontFamily: 'Pacifico',
                color: TwColors.text(context),
                fontStyle: FontStyle.italic,
              )),
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrivacySettingsPage()),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            const WaveBackground(
              colors: [Colors.blue, Colors.purple],
              numberOfWaves: 3,
              amplitude: 80.0,
              animationDuration: Duration(seconds: 8),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPublicChallenges(),
                  _buildFriendsList(),
                  _buildCommunityPosts(),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildPublicChallenges() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  12), // Tailwind-inspired medium radius (12px)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Public Challenges',
                    style: TwTextStyles.body(context).copyWith(
                      fontFamily: 'Pacifico',
                      color: TwColors.text(context),
                    )),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8), // Slightly smaller radius for the button
                    ),
                  ),
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 210,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildChallengeCard('7-Day Fitness Challenge', '3 days left',
                    '2.1k participants'),
                _buildChallengeCard(
                    'Weekly Reading Goal', '6 days left', '850 participants'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
      String title, String duration, String participants) {
    return Container(
      width: 260,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.emoji_events, size: 40, color: Colors.amber),
          const SizedBox(height: 8),
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(duration, style: const TextStyle(color: Colors.grey)),
          Text(participants, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () =>
                setState(() => _isChallengeJoined = !_isChallengeJoined),
            child: Text(_isChallengeJoined ? 'Joined' : 'Join Challenge'),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Friends',
                  style: TwTextStyles.body(context).copyWith(
                    fontFamily: 'Pacifico',
                    color: TwColors.text(context),
                  )),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                  8, (index) => _buildFriendItem('User ${index + 1}')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(String name) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color.fromARGB(
                255, 251, 207, 187), // Light background for the icon
            child: Icon(Icons.face, size: 45),
          ),
          const SizedBox(height: 4),
          Text(name, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildCommunityPosts() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Posts',
              style: TwTextStyles.body(context).copyWith(
                fontFamily: 'Pacifico',
                color: TwColors.text(context),
              )),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) => _buildPostItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(
            radius: 20,
            backgroundColor: Color.fromARGB(
                255, 251, 207, 187), // Light background for the icon
            child: Icon(Icons.face, size: 30),
          ),
          title: Text('User ${index + 1}'),
          subtitle: const Text('2h ago'),
        ),
        const Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore...'),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: Icon(
                  _likedPosts[index] ? Icons.favorite : Icons.favorite_border,
                  color: _likedPosts[index] ? Colors.red : null),
              onPressed: () =>
                  setState(() => _likedPosts[index] = !_likedPosts[index]),
            ),
            IconButton(icon: const Icon(Icons.comment), onPressed: () {}),
            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          ],
        ),
      ],
    );
  }
}

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Who can see my posts'),
            trailing: DropdownButton<String>(
              value: 'Friends',
              items: ['Public', 'Friends', 'Only me']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {},
            ),
          ),
          SwitchListTile(
            title: const Text('Allow friend requests'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: const Text('Show activity status'),
            value: true,
            onChanged: (value) {},
          ),
          ListTile(
            title: const Text('Blocked Users'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
