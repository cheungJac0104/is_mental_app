import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:is_mb_app/models/api_response.dart';
import 'package:is_mb_app/models/challenge.dart';
import 'package:is_mb_app/models/journal_extension.dart';
import '../api_routes/api_service.dart';
import '../models/friendship.dart';
import '../models/journal.dart';
import 'friend_selection_dialog.dart';
import 'tailwind.dart';

class CommunityChallenges extends StatefulWidget {
  final List<Challenge> challenges;
  final Set<String> joinedChallenges;
  final Map<String, int> participates;
  final Function(String, bool) onChallengeToggle;
  final String userId;
  final ApiService apiService;
  final List<Friendship> friends;

  const CommunityChallenges(
      {super.key,
      required this.challenges,
      required this.joinedChallenges,
      required this.participates,
      required this.onChallengeToggle,
      required this.userId,
      required this.apiService,
      required this.friends});

  @override
  State<CommunityChallenges> createState() => _CommunityChallengesState();
}

class _CommunityChallengesState extends State<CommunityChallenges> {
  final TextEditingController _journalContentController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final publicChallenges =
        widget.challenges.where((c) => c.title != null).toList();

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Challenges',
                style: TwTextStyles.body(context).copyWith(
                  fontFamily: 'Pacifico',
                  color: TwColors.text(context),
                ),
              ),
              TextButton(
                onPressed: () => _showAllChallenges(publicChallenges),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 210,
            child: publicChallenges.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: publicChallenges.length,
                    itemBuilder: (context, index) {
                      final challenge = publicChallenges[index];
                      final participantCount = widget.participates.entries
                          .singleWhere((e) => e.key == challenge.challengeId)
                          .value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildChallengeCard(
                          challenge.title ?? 'Untitled Challenge',
                          _getRemainingTime(challenge.completionDate),
                          '$participantCount participants',
                          challenge.challengeId ?? "",
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No challenges available',
        style: TextStyle(color: TwColors.text(context)),
      ),
    );
  }

  String _getRemainingTime(DateTime? endDate) {
    if (endDate == null) return 'No deadline';
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} days left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours left';
    } else {
      return 'Ending soon';
    }
  }

  Widget _buildChallengeCard(
      String title, String duration, String participants, String challengeId) {
    bool isChallengeJoined = widget.joinedChallenges.contains(challengeId);

    void toggleChallenge() {
      widget.onChallengeToggle(challengeId, isChallengeJoined);
    }

    return Container(
      width: 300,
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
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text("$duration | $participants",
              style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: toggleChallenge,
            child: Text(isChallengeJoined ? 'Joined' : 'Join Challenge'),
          ),
        ],
      ),
    );
  }

  void _showAllChallenges(List<Challenge> challenges) {
    final joinedChallenges = challenges
        .where((c) => widget.joinedChallenges.contains(c.challengeId))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              Text(
                'Your Challenges',
                style: TwTextStyles.heading1(context),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: joinedChallenges.isEmpty
                    ? _buildEmptyJoinedChallenges()
                    : ListView.builder(
                        itemCount: joinedChallenges.length,
                        itemBuilder: (context, index) {
                          final challenge = joinedChallenges[index];
                          return _buildJoinedChallengeItem(challenge);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJoinedChallengeItem(Challenge challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  challenge.title ?? 'Untitled Challenge',
                  style: TwTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _leaveChallenge(challenge.challengeId ?? ""),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getRemainingTime(challenge.completionDate),
              style: TwTextStyles.body(context).copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            journalPart(challenge),
          ],
        ),
      ),
    );
  }

  Widget journalPart(Challenge challenge) {
    return FutureBuilder<Response<dynamic>>(
      future: widget.apiService
          .getChallengeProgress(widget.userId, challenge.challengeId ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading progress'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No progress data available'));
        }

        try {
          final progressJson = widget.apiService.getResBodyJson(snapshot.data!);

          if (!progressJson['success']) {
            return _buildAddJournalButton(context, challenge);
          }

          final progress = JournalResponse.fromJson(progressJson);
          final journal = progress.data;

          return Column(
            children: [
              LinearProgressIndicator(
                value: (journal.journalProgress ?? 0.0) / 100,
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              Text(
                journal.progressText,
                style: TwTextStyles.body(context),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showJournalOptions(context, journal),
                      child: const Text('Manage Journal'),
                    ),
                  ),
                ],
              ),
            ],
          );
        } catch (e) {
          debugPrint('Error parsing progress: $e');
          return const Center(child: Text('Error loading progress'));
        }
      },
    );
  }

  Widget _buildAddJournalButton(BuildContext context, Challenge challenge) {
    final journal = Journal(
        challengeId: challenge.challengeId ?? "",
        title: challenge.title ?? "",
        entryId: "",
        journalContent: "",
        journalProgress: 0,
        completionDate: challenge.completionDate ?? DateTime.now(),
        daysRemaining:
            challenge.completionDate?.difference(DateTime.now()).inDays ?? 0);
    return ElevatedButton(
      onPressed: () => _addNewJournalEntry(context, journal),
      child: const Text('Add Journal Entry'),
    );
  }

  Future<void> _showJournalOptions(
      BuildContext context, Journal journal) async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('View Journal'),
            onTap: () {
              Navigator.pop(context);
              _viewJournalProgress(journal);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Journal',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await _deleteJournalEntry(journal.entryId);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateJournalProgress(
      BuildContext context,
      String challengeId,
      int currentProgress,
      String entryId,
      String? shareUserId,
      bool isShared) async {
    if (!mounted) return;
    try {
      final response = await widget.apiService.updateChallengeProgress(
          widget.userId,
          challengeId,
          entryId,
          currentProgress,
          shareUserId,
          isShared);

      final result = widget.apiService.getResBodyJson(response);
      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress updated!')),
        );
      } else {
        throw Exception(result['message'] ?? 'Update failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteJournalEntry(
    String entryId,
  ) async {
    try {
      final response = await widget.apiService.deleteChallengeJournal(
        widget.userId,
        entryId,
      );

      final result = widget.apiService.getResBodyJson(response);
      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal deleted')),
        );
      } else {
        throw Exception(result['message'] ?? 'Deletion failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Add this to your state class

  Future<void> _addNewJournalEntry(
      BuildContext context, Journal journal) async {
    // Reset form state
    _journalContentController.clear();
    double journalProgress = (journal.journalProgress ?? 0).toDouble();
    bool isSharingWithFriend = false;
    Friend? sharedFriend;

    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            StatefulBuilder(builder: (context, setModalState) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'New Journal Entry',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _journalContentController,
                        decoration: InputDecoration(
                          labelText: 'Reflect on your progress...',
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                        ),
                        maxLines: 5,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please write something in your journal'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Progress',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          Chip(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            label: Text(
                              '${journalProgress.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor:
                              Theme.of(context).colorScheme.primary,
                          inactiveTrackColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          thumbColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: Slider(
                            value: journalProgress,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: journalProgress.toStringAsFixed(1),
                            onChanged: (value) {
                              setModalState(() => journalProgress = value);
                            }),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        margin: EdgeInsets.zero,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: isSharingWithFriend,
                            onChanged: (value) async {
                              if (value == true) {
                                final selected =
                                    await _selectFriendToShare(context);
                                setModalState(() {
                                  isSharingWithFriend = selected != null;
                                  sharedFriend = selected;
                                });
                              } else {
                                setModalState(() {
                                  isSharingWithFriend = false;
                                  sharedFriend = null;
                                });
                              }
                            },
                          ),
                          title: Text(
                            'Share with Friend',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          trailing: const Icon(Icons.share),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (isSharingWithFriend)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Sharing with: ${sharedFriend?.username}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          FilledButton.tonal(
                            onPressed: () async {
                              if (_journalContentController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Please enter journal content')),
                                );
                                return;
                              }

                              final journalEntry = {
                                'content': _journalContentController.text,
                                'challengeProgress': journalProgress,
                                'sharedWithFriend': isSharingWithFriend
                                    ? {'userId': sharedFriend!.userId}
                                    : null,
                                'isSharedPublicly': isSharingWithFriend,
                              };

                              Navigator.pop(context);
                              await _submitJournalEntry(
                                  journal.challengeId, journalEntry);
                            },
                            child: const Text('Save Entry'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Future<Friend?> _selectFriendToShare(BuildContext context) async {
    final selected = await showModalBottomSheet<Friendship>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FriendDropdownSheet(friends: widget.friends),
    );

    return selected?.friend;
  }

  Future<void> _submitJournalEntry(
      String challengeId, Map<String, dynamic> journalData) async {
    try {
      final response = await widget.apiService.addChallengeJournal(
        widget.userId,
        challengeId,
        journalData,
      );

      final result = widget.apiService.getResBodyJson(response);
      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal created successfully!')),
        );
      } else {
        throw Exception(result['message'] ?? 'Failed to create journal');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _viewJournalProgress(Journal journal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Journal Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      Navigator.pop(context);
                      _editJournalEntry(context, journal);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_graph,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (journal.journalProgress ?? 0) / 100,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        color: Theme.of(context).colorScheme.primary,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(journal.journalProgress ?? 0).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notes,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Reflection',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        journal.journalContent,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              if (journal.friendTag != null) ...[
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Shared With',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              journal.friendTag!.username
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(journal.friendTag!.username),
                          subtitle: Text(
                            'Shared on ${journal.friendTag!.userId}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editJournalEntry(BuildContext context, Journal journal) {
    final contentController =
        TextEditingController(text: journal.journalContent);
    double currentProgress = journal.journalProgress?.toDouble() ?? 0.0;
    bool isShared = journal.friendTag != null;
    String? sharedFriendId = journal.friendTag?.userId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Edit Journal Entry',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: contentController,
                      decoration: InputDecoration(
                        labelText: 'Journal Content',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Progress',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        Chip(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          label: Text(
                            '${currentProgress.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        thumbColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Slider(
                        value: currentProgress,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: currentProgress.toStringAsFixed(1),
                        onChanged: (value) {
                          setModalState(() => currentProgress = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      margin: EdgeInsets.zero,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: isShared,
                          onChanged: (value) {
                            setModalState(() {
                              isShared = value ?? false;
                              if (isShared && sharedFriendId == null) {
                                _selectFriendToShare(context).then((friend) {
                                  if (friend != null) {
                                    setModalState(() {
                                      sharedFriendId = friend.userId;
                                    });
                                  }
                                });
                              }
                            });
                          },
                        ),
                        title: Text(
                          'Share with Friend',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: const Icon(Icons.share),
                      ),
                    ),
                    if (isShared && sharedFriendId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Sharing with: ${widget.friends.firstWhere((f) => f.friend.userId == sharedFriendId).friend.username}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.tonal(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _updateJournalProgress(
                              context,
                              journal.challengeId,
                              currentProgress.round(),
                              journal.entryId,
                              sharedFriendId,
                              isShared,
                            );
                          },
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }

  Widget _buildEmptyJoinedChallenges() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 60,
            color: TwColors.text(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No challenges joined yet',
            style: TwTextStyles.body(context),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Browse Challenges'),
          ),
        ],
      ),
    );
  }

  void _leaveChallenge(String challengeId) async {
    try {
      widget.onChallengeToggle(challengeId, true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Left the challenge')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
