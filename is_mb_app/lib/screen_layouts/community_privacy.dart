import 'package:flutter/material.dart';

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
