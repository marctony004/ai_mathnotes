import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedTheme = themeProvider.currentThemeMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("⚙️ Settings"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Select Theme",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          RadioListTile<ThemeModeOption>(
            title: const Text('🌞 Light Theme'),
            value: ThemeModeOption.light,
            groupValue: selectedTheme,
            onChanged: (val) => themeProvider.setTheme(val!),
          ),
          RadioListTile<ThemeModeOption>(
            title: const Text('🌙 Dark Theme'),
            value: ThemeModeOption.dark,
            groupValue: selectedTheme,
            onChanged: (val) => themeProvider.setTheme(val!),
          ),
          RadioListTile<ThemeModeOption>(
            title: const Text('🌐 Cyberpunk Theme'),
            value: ThemeModeOption.cyberpunk,
            groupValue: selectedTheme,
            onChanged: (val) => themeProvider.setTheme(val!),
          ),
          RadioListTile<ThemeModeOption>(
            title: const Text('🦁 Gryffindor Theme'),
            value: ThemeModeOption.gryffindor,
            groupValue: selectedTheme,
            onChanged: (val) => themeProvider.setTheme(val!),
          ),
          const Divider(height: 32),
          const Text(
            "Stylus Settings",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text("Enable Stylus-Only Drawing ✍️"),
            value: themeProvider.stylusOnlyMode,
            onChanged: (value) => themeProvider.setStylusOnly(value),
          ),
        ],
      ),
    );
  }
}
