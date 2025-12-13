import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

import 'package:dark_market/ui/screens/login_screen.dart';
import 'package:dark_market/ui/screens/home_screen.dart';
import 'package:dark_market/ui/screens/view_auction_screen.dart';
import 'package:dark_market/ui/screens/create_auction_screen.dart';
import 'package:dark_market/ui/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (_) {}

  runApp(
    // Wrap the entire app with ProviderScope for Riverpod
    const ProviderScope(
      child: DarkMarketApp(),
    ),
  );
}

class DarkMarketApp extends StatefulWidget {
  const DarkMarketApp({super.key});

  @override
  State<DarkMarketApp> createState() => DarkMarketAppState();
}

class DarkMarketAppState extends State<DarkMarketApp> {
  late final GoRouter _goRouter;

  @override
  void initState() {
    super.initState();
    _goRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/create',
          builder: (_, _) => const CreateAuctionScreen(),
        ),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        GoRoute(
          path: '/view/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ViewAuctionScreen(id: id);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: _goRouter,
    );
  }
}
