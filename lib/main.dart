import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

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

  // Disable persistence to avoid 'unavailable' issues on simulator
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);

  // Also disable for specific database 'harumanna'
  FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'harumanna').settings = const Settings(persistenceEnabled: false);

  // Initialize notification service
  await NotificationService().initialize();

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
        home: const HomeScreen(),
      ),
    );
  }
}
