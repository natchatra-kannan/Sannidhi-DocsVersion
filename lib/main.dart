import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'features/navigation/main_layout.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(
    const ProviderScope(
      child: SannidhiApp(),
    ),
  );
}

class SannidhiApp extends ConsumerWidget {
  const SannidhiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'SANNIDHI - Culture Operating System',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: SannidhiTheme.lightTheme,
      darkTheme: SannidhiTheme.darkTheme,
      routerConfig: router,
    );
  }
}
