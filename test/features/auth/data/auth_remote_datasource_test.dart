import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:taskgi/core/services/firebase_auth_service.dart';
import 'package:taskgi/features/auth/data/datasources/auth_remote_datasource.dart';

class MockAuthService extends Mock implements FirebaseAuthService {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockAuthService mockService;

  setUp(() {
    mockService = MockAuthService();
    dataSource = AuthRemoteDataSourceImpl(mockService);
  });

  test('login returns User', () async {
    final user = MockUser();
    final credential = MockUserCredential();

    when(() => credential.user).thenReturn(user);

    when(() => mockService.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => credential);

    final result = await dataSource.login(
      email: 'test@test.com',
      password: '123456',
    );

    expect(result, user);
  });
}