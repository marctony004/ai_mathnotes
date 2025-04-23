import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'screens/home_screen.dart';
import 'folder_system/folder_home.dart';
import 'calendar/calendar_screen.dart'; 
import 'screens/splash_screen.dart';
import '../screens/home_screen.dart';
import 'screens/syllabus_preview_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme();

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI MathNotes',
      theme: themeProvider.currentTheme,
      initialRoute: '/',
      routes: {
  '/': (context) => const OrbitSplash(), // ← Launches this first
  '/folders': (context) => const FolderHomePage(),
  '/calendar': (context) => const CalendarScreen(),
  '/syllabus': (context) => const SyllabusPreviewScreen(),
},

    );
  }
}
