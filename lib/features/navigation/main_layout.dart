import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../services/mock_data.dart';

// Riverpod Provider for theme mode selection
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  int _getSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/veedu')) return 1;
    if (location.startsWith('/makkal')) return 2;
    if (location.startsWith('/booking')) return 3;
    if (location.startsWith('/awards')) return 4;
    if (location.startsWith('/punch')) return 5;
    if (location.startsWith('/profile')) return 6;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/veedu');
        break;
      case 2:
        context.go('/makkal');
        break;
      case 3:
        context.go('/booking');
        break;
      case 4:
        context.go('/awards');
        break;
      case 5:
        context.go('/punch');
        break;
      case 6:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final GoRouterState routerState = GoRouterState.of(context);
    final String location = routerState.uri.toString();
    final int selectedIndex = _getSelectedIndex(location);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    final List<Map<String, dynamic>> navItems = [
      {'label': 'S.NIDHI', 'icon': Icons.home_rounded},
      {'label': '△வீ', 'icon': Icons.layers_rounded},
      {'label': 'Makkal', 'icon': Icons.people_rounded},
      {'label': 'Booking', 'icon': Icons.meeting_room_rounded},
      {'label': 'Awards 25\'', 'icon': Icons.emoji_events_rounded},
      {'label': 'Punchu', 'icon': Icons.check_circle_outline_rounded},
      {'label': 'Profile', 'icon': Icons.account_circle_rounded},
    ];

    Widget buildSidebar() {
      return Container(
        width: 260,
        decoration: BoxDecoration(
          color: isDark ? SannidhiTheme.darkCard : Colors.white,
          border: Border(
            right: BorderSide(
              color: isDark ? SannidhiTheme.darkBorder : SannidhiTheme.lightBorder,
            ),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [SannidhiTheme.teal, SannidhiTheme.iceBlue],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.layers, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'S.NIDHI',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: isDark ? Colors.white : SannidhiTheme.darkBg,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Navigation Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemCount: navItems.length,
                itemBuilder: (context, index) {
                  final item = navItems[index];
                  final isSelected = index == selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: InkWell(
                      onTap: () => _onItemTapped(index, context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SannidhiTheme.teal.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? SannidhiTheme.teal.withOpacity(0.3) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              color: isSelected
                                  ? SannidhiTheme.teal
                                  : (isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark),
                              size: 22,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              item['label'] as String,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? SannidhiTheme.teal
                                    : (isDark ? SannidhiTheme.textLight : SannidhiTheme.textDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Footer (User info & Settings toggle)
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(MockData.currentUser.avatarUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              MockData.currentUser.fullName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${MockData.currentUser.balance} Coins',
                              style: const TextStyle(
                                color: SannidhiTheme.teal,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          size: 20,
                        ),
                        onPressed: () {
                          ref.read(themeModeProvider.notifier).state =
                              themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/login'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: isDark ? SannidhiTheme.darkBorder : SannidhiTheme.lightBorder,
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Sign Out', style: TextStyle(fontSize: 12)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: !isDesktop
          ? AppBar(
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [SannidhiTheme.teal, SannidhiTheme.iceBlue],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.layers, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text('SANNIDHI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              actions: [
                Chip(
                  avatar: const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 16),
                  label: Text('${MockData.currentUser.balance} Coins', style: const TextStyle(fontSize: 12)),
                  backgroundColor: isDark ? SannidhiTheme.darkCard : SannidhiTheme.iceBlueLight,
                  side: BorderSide.none,
                ),
                IconButton(
                  icon: Icon(
                    themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  ),
                  onPressed: () {
                    ref.read(themeModeProvider.notifier).state =
                        themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => context.go('/login'),
                ),
              ],
            )
          : null,
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(index, context),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: SannidhiTheme.teal,
              unselectedItemColor: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
              items: navItems
                  .map((item) => BottomNavigationBarItem(
                        icon: Icon(item['icon'] as IconData),
                        label: item['label'] as String,
                      ))
                  .toList(),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop) buildSidebar(),
          Expanded(
            child: Container(
              color: isDark ? SannidhiTheme.darkBg : SannidhiTheme.lightBg,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
