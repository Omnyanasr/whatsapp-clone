import 'package:flutter/material.dart';
import 'package:whatsapp/theme/app_theme.dart';
import 'package:whatsapp/views/home_screen.dart';

void main() {
  runApp(const WhatsAppStyleApp());
}

class WhatsAppStyleApp extends StatefulWidget {
  const WhatsAppStyleApp({super.key});

  @override
  State<WhatsAppStyleApp> createState() => _WhatsAppStyleAppState();
}

class _WhatsAppStyleAppState extends State<WhatsAppStyleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp UI',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: HomeShell(onToggleTheme: _toggleTheme),
    );
  }
}
