import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/mock_data.dart';

class MakkalScreen extends StatefulWidget {
  const MakkalScreen({super.key});

  @override
  State<MakkalScreen> createState() => _MakkalScreenState();
}

class _MakkalScreenState extends State<MakkalScreen> {
  String _selectedTeamId = 'all';

  void _showProfileDetails(UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? SannidhiTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Container(
            width: 400,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(profile.avatarUrl),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Text(
                  profile.role,
                  style: const TextStyle(color: SannidhiTheme.teal, fontSize: 14),
                ),
                Text(
                  profile.email,
                  style: const TextStyle(color: SannidhiTheme.textMutedDark, fontSize: 12),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCoinStat('Sent', profile.coinsSent, Colors.blue),
                    _buildCoinStat('Received', profile.coinsReceived, Colors.orange),
                    _buildCoinStat('Balance', profile.balance, Colors.teal),
                  ],
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Achievements & Badges',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.achievements.map((ach) {
                    return Chip(
                      label: Text(ach, style: const TextStyle(fontSize: 11)),
                      backgroundColor: SannidhiTheme.teal.withOpacity(0.1),
                      side: BorderSide(color: SannidhiTheme.teal.withOpacity(0.3)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }

  Widget _buildCoinStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: SannidhiTheme.textMutedDark),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedTeam = _selectedTeamId == 'all'
        ? null
        : MockData.teams.firstWhere((t) => t.id == _selectedTeamId);

    final List<UserProfile> activeMembers = [];
    final List<UserProfile> alumniMembers = [];

    if (selectedTeam == null) {
      // Show all profiles
      activeMembers.addAll(MockData.allProfiles);
    } else {
      for (var id in selectedTeam.memberIds) {
        final prof = MockData.allProfiles.firstWhere((p) => p.id == id,
            orElse: () => UserProfile(
                  id: 'unknown',
                  email: '',
                  fullName: 'Unknown User',
                  role: '',
                  avatarUrl: '',
                  coinsReceived: 0,
                  coinsSent: 0,
                  coinsDeducted: 0,
                  balance: 0,
                  achievements: [],
                ));
        if (prof.id != 'unknown') {
          activeMembers.add(prof);
        }
      }
      for (var id in selectedTeam.alumniIds) {
        final prof = MockData.allProfiles.firstWhere((p) => p.id == id,
            orElse: () => UserProfile(
                  id: 'unknown',
                  email: '',
                  fullName: 'Unknown User',
                  role: '',
                  avatarUrl: '',
                  coinsReceived: 0,
                  coinsSent: 0,
                  coinsDeducted: 0,
                  balance: 0,
                  achievements: [],
                ));
        if (prof.id != 'unknown') {
          alumniMembers.add(prof);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Makkal Employee Directory',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Explore teams, member networks, and individual profiles',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Teams'),
                    selected: _selectedTeamId == 'all',
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedTeamId = 'all');
                    },
                    selectedColor: SannidhiTheme.teal.withOpacity(0.2),
                    checkmarkColor: SannidhiTheme.teal,
                  ),
                  const SizedBox(width: 8),
                  ...MockData.teams.map((t) {
                    final isSelected = _selectedTeamId == t.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(t.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedTeamId = t.id);
                        },
                        selectedColor: SannidhiTheme.teal.withOpacity(0.2),
                        checkmarkColor: SannidhiTheme.teal,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (selectedTeam != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedTeam.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SannidhiTheme.teal),
                      ),
                      const SizedBox(height: 4),
                      Text(selectedTeam.description, style: const TextStyle(fontSize: 13, height: 1.4)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Lead: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(selectedTeam.leadName, style: const TextStyle(fontSize: 13, color: SannidhiTheme.iceBlue, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Active Members Grid
            Text(
              'Active Members (${activeMembers.length})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.2,
              ),
              itemCount: activeMembers.length,
              itemBuilder: (context, index) {
                final member = activeMembers[index];
                return Card(
                  child: InkWell(
                    onTap: () => _showProfileDetails(member),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(member.avatarUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  member.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  member.role,
                                  style: const TextStyle(fontSize: 11, color: SannidhiTheme.teal),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            if (selectedTeam != null && alumniMembers.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'Alumni Members (${alumniMembers.length})',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.2,
                ),
                itemCount: alumniMembers.length,
                itemBuilder: (context, index) {
                  final alumni = alumniMembers[index];
                  return Card(
                    child: Opacity(
                      opacity: 0.7,
                      child: InkWell(
                        onTap: () => _showProfileDetails(alumni),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(alumni.avatarUrl),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      alumni.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      alumni.role,
                                      style: const TextStyle(fontSize: 11, color: SannidhiTheme.textMutedDark),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
