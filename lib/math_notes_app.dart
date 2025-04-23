import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'folder_system/folder_home.dart';

class MathNotesApp extends StatelessWidget {
  const MathNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'AI MathNotes',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: const FolderHomePage(),
    );
  }
}
