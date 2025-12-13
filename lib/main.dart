import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart'; 
import 'screens/qt_screen.dart'; 
import 'screens/prayer_screen.dart'; 
import 'widgets/bottom_nav.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'HaruManna',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScaffold(),
      ),
    );
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    // We use consumer to listen to tab changes if needed for Scaffold, 
    // but the body will switch based on provider.
    final activeTab = context.watch<AppProvider>().activeTab;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: activeTab.index,
          children: const [
            HomeScreen(),
            QTScreen(),
            PrayerScreen(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}
