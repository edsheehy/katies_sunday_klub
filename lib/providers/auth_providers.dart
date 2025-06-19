import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the Firebase Auth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// /// Provides the Firestore instance
// final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
//   return FirebaseFirestore.instance;
// });

// -----------------
// Auth Providers
// -----------------

/// Streams authentication state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Provides the current user, or null if not authenticated
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// Determines if a user is currently authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Authentication state class to manage auth operations
class AuthState {
  final bool isLoading;
  final String? statusMessage;
  final Object? error;

  const AuthState({
    this.isLoading = false,
    this.statusMessage,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? statusMessage,
    Object? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      statusMessage: statusMessage ?? this.statusMessage,
      error: error,
    );
  }
}

/// Auth notifier to handle authentication operations
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState());

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        statusMessage: 'Email and password cannot be empty',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      statusMessage: 'Signing in...',
      error: null,
    );

    try {
      final auth = _ref.read(firebaseAuthProvider);
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        statusMessage: 'Signed in as ${userCredential.user?.email}',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        statusMessage: 'Error: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Sign in as Edward (predefined credentials)
  Future<void> signInAsEd() async {
    state = state.copyWith(
      isLoading: true,
      statusMessage: 'Signing in as Edward...',
      error: null,
    );

    try {
      final auth = _ref.read(firebaseAuthProvider);
      final userCredential = await auth.signInWithEmailAndPassword(
        email: 'edsheehy@gmail.com',
        password: 'Admirkah02*0',
      );

      state = state.copyWith(
        isLoading: false,
        statusMessage: 'Signed in as ${userCredential.user?.email}',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        statusMessage: 'Error: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = state.copyWith(
      isLoading: true,
      statusMessage: 'Signing out...',
    );

    try {
      final auth = _ref.read(firebaseAuthProvider);
      await auth.signOut();

      state = const AuthState(
        isLoading: false,
        statusMessage: 'Signed out successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        statusMessage: 'Error signing out: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Reset the auth state
  void resetState() {
    state = const AuthState();
  }
}

/// Provider for auth operations
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
