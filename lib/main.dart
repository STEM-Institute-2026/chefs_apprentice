import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; 
import 'screens/main_shell_screen.dart';
import 'screens/custom_auth_screen.dart';
import 'models/models.dart';
import 'services/data_loader_service.dart';
import 'services/history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Loads static recipes from JSON and syncs the live user profile from Firestore
  Future<AppData> _initAppData() async {
    await HistoryService.loadUserProfile();
    return await DataLoaderService.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chef's Apprentice",
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.creamBackground,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData) {
            return const CustomAuthScreen();
          }

          return FutureBuilder<AppData>(
            future: _initAppData(),
            builder: (context, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: AppColors.oliveSecondary),
                  ),
                );
              }

              if (dataSnapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Failed to load data: ${dataSnapshot.error}')),
                );
              }

              final appData = dataSnapshot.data!;

              return MainShellScreen(
                recipes: appData.recipes,
                userProfile: HistoryService.currentProfile,
              );
            },
          );
        },
      ),
    );
  }
}