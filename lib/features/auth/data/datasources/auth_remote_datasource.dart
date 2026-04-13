import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_auth_service.dart';

abstract class AuthRemoteDataSource {
  Future<User> signUp({
    required String email,
    required String password,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuthService authService;

  AuthRemoteDataSourceImpl(this.authService);

  @override
  Future<User> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await authService.signUp(
      email: email,
      password: password,
    );

    return credential.user!;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final credential = await authService.login(
      email: email,
      password: password,
    );

    return credential.user!;
  }

  @override
  Future<void> logout() async {
    await authService.logout();
  }

  @override
  Stream<User?> get authStateChanges => authService.authStateChanges;
}