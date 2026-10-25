import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/main_shell_screen.dart';
import 'screens/custom_auth_screen.dart';
import 'screens/onboarding_screen.dart';
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
      home: const AuthGate(),
    );
  }
}

/// Decides which screen to display based on authentication
/// and the user's onboarding status.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const CustomAuthScreen();
        }

        return UserProfileGate(
          key: ValueKey(user.uid),
        );
      },
    );
  }
}

/// Loads the user's profile and checks onboarding completion.
class UserProfileGate extends StatefulWidget {
  const UserProfileGate({super.key});

  @override
  State<UserProfileGate> createState() => _UserProfileGateState();
}

class _UserProfileGateState extends State<UserProfileGate> {
  late Future<UserProfileModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<UserProfileModel> _loadProfile() async {
    await HistoryService.loadUserProfile();
    return HistoryService.currentProfile;
  }

  /// Reload the profile after onboarding has saved successfully.
  void _onboardingCompleted() {
    if (!mounted) return;
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  void _retryLoadingProfile() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfileModel>(
      future: _profileFuture,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.oliveSecondary,
              ),
            ),
          );
        }

        if (profileSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Unable to load your profile.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _retryLoadingProfile,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final profile = profileSnapshot.data!;

        if (!profile.onboardingCompleted) {
          return OnboardingScreen(
            onCompleted: _onboardingCompleted,
          );
        }

        return const AuthenticatedAppLoader();
      },
    );
  }
}

/// Loads the app's static data after onboarding is complete.
class AuthenticatedAppLoader extends StatefulWidget {
  const AuthenticatedAppLoader({super.key});

  @override
  State<AuthenticatedAppLoader> createState() =>
      _AuthenticatedAppLoaderState();
}

class _AuthenticatedAppLoaderState extends State<AuthenticatedAppLoader> {
  late Future<AppData> _appDataFuture;

  @override
  void initState() {
    super.initState();
    _appDataFuture = _initAppData();
  }

  Future<AppData> _initAppData() async {
    // User profile has already been loaded by UserProfileGate.
    return DataLoaderService.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppData>(
      future: _appDataFuture,
      builder: (context, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.oliveSecondary,
              ),
            ),
          );
        }

        if (dataSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load data: ${dataSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final appData = dataSnapshot.data!;

        return MainShellScreen(
          recipes: appData.recipes,
          skillModules: appData.skillModules,
          cuisineModules: appData.cuisineModules,
          essentialsData: appData.essentialsData,
          badges: appData.badges,
          userProfile: HistoryService.currentProfile,
        );
      },
    );
  }
}
