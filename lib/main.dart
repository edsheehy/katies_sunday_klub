import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katies_sunday_klub/providers/auth_providers.dart';
import 'package:katies_sunday_klub/providers/package_info_provider.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';

// Main function to initialize Firebase and run the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

// Main App
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(packageInfoProvider);
    return MaterialApp(
      title: 'Katie\'s Sunday Klub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}

// Auth wrapper to handle authentication state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text('Authentication error: $error')),
      ),
    );
  }
}

// Auth Screen
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                // Regular sign in button (commented out as in original code)
                ElevatedButton(
                  onPressed: authState.isLoading
                    ? null
                    : () => ref.read(authProvider.notifier).signIn(
                        _emailController.text,
                        _passwordController.text,
                      ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: authState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Sign In'),
                  ),
                ),
                // const SizedBox(height: 16),
                // ElevatedButton(
                //   onPressed: authState.isLoading
                //       ? null
                //       : () => ref.read(authProvider.notifier).signInAsEd(),
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                //     child: authState.isLoading
                //         ? const CircularProgressIndicator()
                //         : const Text('Sign In As Edward'),
                //   ),
                // ),
                const SizedBox(height: 16),
                if (authState.statusMessage != null)
                  Text(
                    authState.statusMessage!,
                    style: TextStyle(
                      color: authState.error != null ? Colors.red : Colors.green,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
