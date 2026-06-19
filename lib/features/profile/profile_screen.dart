import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = MockData.currentUser;

    // Mock history entries
    final List<Map<String, dynamic>> history = [
      {'title': 'Nomination Bonus (Excellence)', 'amount': 150, 'isCredit': true, 'date': 'June 10, 2026'},
      {'title': 'Sent appreciation coin to Peter Parker', 'amount': 50, 'isCredit': false, 'date': 'June 09, 2026'},
      {'title': 'Weekly Alignment Active Streak Rewards', 'amount': 200, 'isCredit': true, 'date': 'June 08, 2026'},
      {'title': 'Late check-in deduction (Meeting Room)', 'amount': 50, 'isCredit': false, 'date': 'June 04, 2026'},
    ];

    return SelectionArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My SANNIDHI Profile',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage your credentials, achievements log, and culture coins balance',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel: Core Credentials and Coin metrics
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Avatar and info card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundImage: NetworkImage(user.avatarUrl),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.fullName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                            Text(
                              user.role,
                              style: const TextStyle(color: SannidhiTheme.teal, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.email_outlined, size: 14, color: SannidhiTheme.textMutedDark),
                                const SizedBox(width: 6),
                                Text(
                                  user.email,
                                  style: const TextStyle(color: SannidhiTheme.textMutedDark, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Coins stats ledger card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.monetization_on_rounded, color: Colors.amber),
                                SizedBox(width: 8),
                                Text(
                                  'Culture Coins Ledger',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            
                            // Coins Received
                            _buildLedgerRow('Received', user.coinsReceived, Colors.orange),
                            const Divider(),
                            // Coins Sent
                            _buildLedgerRow('Sent', user.coinsSent, Colors.blue),
                            const Divider(),
                            // Coins Deducted
                            _buildLedgerRow('Deducted', user.coinsDeducted, Colors.redAccent),
                            const Divider(),
                            // Net Balance
                            _buildLedgerRow('Current Balance', user.balance, SannidhiTheme.teal, isBold: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Panel: Achievements and Transaction ledger logs
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Achievements Cards
                    Text(
                      'Achievements & Recognition History',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: user.achievements.map((ach) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: SannidhiTheme.teal.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: SannidhiTheme.teal.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.stars, color: Colors.amber, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    ach,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Transaction Activity
                    Text(
                      'Recent Activity Ledger',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final tx = history[index];
                        final isCredit = tx['isCredit'] as bool;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isCredit ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                              child: Icon(
                                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isCredit ? Colors.green : Colors.redAccent,
                                size: 18,
                              ),
                            ),
                            title: Text(tx['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            subtitle: Text(tx['date'] as String, style: const TextStyle(fontSize: 11, color: SannidhiTheme.textMutedDark)),
                            trailing: Text(
                              '${isCredit ? "+" : "-"}${tx['amount']} Coins',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCredit ? Colors.green : Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLedgerRow(String label, int value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 14 : 13,
            ),
          ),
          Text(
            '$value Coins',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
