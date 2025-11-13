
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'data/services/storage_service.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart'; // 👈 import your theme file

import 'package:dark_market/data/services/auction_service.dart';
import 'package:dark_market/data/services/auth_service.dart';
import 'package:dark_market/data/services/storage_service.dart';

import 'package:dark_market/state/auction_provider.dart';
import 'package:dark_market/state/auth_provider.dart';

import 'package:dark_market/ui/screens/login_screen.dart';
import 'package:dark_market/ui/screens/home_screen.dart';
import 'package:dark_market/ui/screens/view_auction_screen.dart';
import 'package:dark_market/ui/screens/create_auction_screen.dart';
import 'package:dark_market/ui/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    FirebaseFirestore.instance.settings =
    const Settings(persistenceEnabled: true);
  } catch (_) {}

  runApp(const DarkMarketApp());
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
        GoRoute(path: '/create', builder: (_, _) => const CreateAuctionScreen()),

        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
      ChangeNotifierProvider(create: (_) {
        final provider = AuctionProvider(AuctionService(), StorageService());
        provider.bindStream();
        return provider;
      }),
    ],
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: _goRouter,
    ),
    );
  }

}




