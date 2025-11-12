import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart'; // 👈 import your theme file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark Market',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,  // theme
      home: Scaffold(
        appBar: AppBar(title: const Text('Dark Market')),
        body: const Center(child: Text('Firebase wired up ✅')),
      ),
    );
  }
}
