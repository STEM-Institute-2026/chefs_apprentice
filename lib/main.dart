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
          // 1. Waiting for auth state check
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. User is logged out -> Show Login Screen
          if (!snapshot.hasData) {
            return const CustomAuthScreen();
          }

          // 3. User is logged in -> Load data once and enter app
          return const AuthenticatedAppLoader();
        },
      ),
    );
  }
}

/// Helper widget to initialize user data once upon successful sign-in
class AuthenticatedAppLoader extends StatefulWidget {
  const AuthenticatedAppLoader({super.key});

  @override
  State<AuthenticatedAppLoader> createState() => _AuthenticatedAppLoaderState();
}

class _AuthenticatedAppLoaderState extends State<AuthenticatedAppLoader> {
  late Future<AppData> _appDataFuture;

  @override
  void initState() {
    super.initState();
    // Cache the future so it only executes once when sign-in completes
    _appDataFuture = _initAppData();
  }

  Future<AppData> _initAppData() async {
    await HistoryService.loadUserProfile();
    return await DataLoaderService.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppData>(
      future: _appDataFuture,
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
            body: Center(
              child: Text('Failed to load data: ${dataSnapshot.error}'),
            ),
          );
        }

        final appData = dataSnapshot.data!;

        return MainShellScreen(
          recipes: appData.recipes,
          skillModules: appData.skillModules,
          cuisineModules: appData.cuisineModules,
          userProfile: HistoryService.currentProfile,
        );
      },
    );
  }
}