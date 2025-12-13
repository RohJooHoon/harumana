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
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDzvw5wmPB7u_2ifobgiBfuvKceQh2O3Ds",
      appId: "1:58660569134:ios:6db1d32d8d8e9802fb1fbf",
      messagingSenderId: "58660569134",
      projectId: "haru-manna-flutter",
      storageBucket: "haru-manna-flutter.firebasestorage.app",
      iosBundleId: "com.jho2.harumanna",
    ),
  );
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
        title: '하루만나',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) => GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child!,
        ),
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
        child: _getScreen(activeTab),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _getScreen(ActiveTab tab) {
    switch (tab) {
      case ActiveTab.home:
        return const HomeScreen();
      case ActiveTab.qt:
        return const QTScreen();
      case ActiveTab.prayer:
        return const PrayerScreen();
    }
  }
}
