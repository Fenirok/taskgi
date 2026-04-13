import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
  }) async {
    final User user = await remoteDataSource.signUp(
      email: email,
      password: password,
    );

    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final User user = await remoteDataSource.login(
      email: email,
      password: password,
    );

    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }
}