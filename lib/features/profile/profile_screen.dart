import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../repositories/interfaces.dart';
import '../../services/mock_data.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = MockData.currentUser;
    final records = ref.watch(attendanceStateProvider);

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

                    // Monthly Attendance Calendar
                    Text(
                      'Attendance Calendar (June 2026)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Monthly Attendance Overview',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Row(
                                  children: [
                                    _LegendItem(color: Color(0xFF22C55E), label: 'Present'),
                                    SizedBox(width: 12),
                                    _LegendItem(color: Color(0xFFEAB308), label: 'Late'),
                                    SizedBox(width: 12),
                                    _LegendItem(color: Color(0xFFEF4444), label: 'Absent'),
                                    SizedBox(width: 12),
                                    _LegendItem(color: Color(0xFF64748B), label: 'Weekend'),
                                  ],
                                )
                              ],
                            ),
                            const Divider(height: 24),
                            // Days of Week Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                                return SizedBox(
                                  width: 44,
                                  child: Text(
                                    day,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: SannidhiTheme.textMutedDark),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            // Calendar Grid
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final double cellWidth = (constraints.maxWidth - 48) / 7;
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(30, (index) {
                                    final dayNumber = index + 1;
                                    
                                    final int rIndex = records.indexWhere(
                                       (r) => r.timestamp.year == 2026 && r.timestamp.month == 6 && r.timestamp.day == dayNumber,
                                     );
                                     final record = rIndex != -1 ? records[rIndex] : null;

                                    final isWeekend = dayNumber == 6 || dayNumber == 7 ||
                                        dayNumber == 13 || dayNumber == 14 ||
                                        dayNumber == 20 || dayNumber == 21 ||
                                        dayNumber == 27 || dayNumber == 28;

                                    Color boxColor;
                                    String tooltipMessage;
                                    IconData? icon;

                                    if (record != null) {
                                      if (record.isLate) {
                                        boxColor = const Color(0xFFEAB308); // Yellow for late
                                        tooltipMessage = "June $dayNumber: Late check-in (${DateFormat('hh:mm a').format(record.timestamp)}) via ${record.mode}";
                                        icon = Icons.alarm_rounded;
                                      } else {
                                        boxColor = const Color(0xFF22C55E); // Green for present
                                        tooltipMessage = "June $dayNumber: Present (${DateFormat('hh:mm a').format(record.timestamp)}) via ${record.mode}";
                                        icon = record.mode == 'Work From Home' ? Icons.home_work_outlined : Icons.check_circle_outline_rounded;
                                      }
                                    } else {
                                      if (isWeekend) {
                                        boxColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
                                        tooltipMessage = "June $dayNumber: Weekend (Off)";
                                      } else {
                                        // Past absentees vs future
                                        final today = DateTime(2026, 6, 19);
                                        final cellDate = DateTime(2026, 6, dayNumber);
                                        if (cellDate.isBefore(today)) {
                                          boxColor = const Color(0xFFEF4444); // Red for absent
                                          tooltipMessage = "June $dayNumber: Absent (Unmarked)";
                                          icon = Icons.close_rounded;
                                        } else {
                                          boxColor = Colors.transparent; // Future
                                          tooltipMessage = "June $dayNumber: Future day";
                                        }
                                      }
                                    }

                                    return Tooltip(
                                      message: tooltipMessage,
                                      child: Container(
                                        width: cellWidth,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: boxColor,
                                          borderRadius: BorderRadius.circular(8),
                                          border: boxColor == Colors.transparent
                                              ? Border.all(color: isDark ? SannidhiTheme.darkBorder : SannidhiTheme.lightBorder)
                                              : null,
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 4,
                                              left: 6,
                                              child: Text(
                                                '$dayNumber',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: boxColor == Colors.transparent
                                                      ? (isDark ? Colors.white54 : Colors.black54)
                                                      : (boxColor == const Color(0xFFEAB308) ? Colors.black87 : Colors.white),
                                                ),
                                              ),
                                            ),
                                            if (icon != null)
                                              Center(
                                                child: Icon(
                                                  icon,
                                                  size: 16,
                                                  color: boxColor == const Color(0xFFEAB308) ? Colors.black87 : Colors.white,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ],
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color == Colors.transparent ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(3),
            border: color == Colors.transparent ? Border.all(color: isDark ? Colors.white54 : Colors.black54) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
