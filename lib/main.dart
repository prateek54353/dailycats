import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const DailyCatsApp());
}

class DailyCatsApp extends HookWidget {
  const DailyCatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(useMaterial3: true);
    return MaterialApp(
      title: 'Daily Cats',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(brightness: Brightness.light),
      darkTheme: theme.copyWith(brightness: Brightness.dark),
      home: const HomeScreen(),
    );
  }
}
