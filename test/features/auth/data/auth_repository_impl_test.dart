import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:taskgi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:taskgi/features/auth/data/repositories/auth_repository_impl.dart';

class MockDataSource extends Mock implements AuthRemoteDataSource {}
class MockUser extends Mock implements User {}

void main() {
  late AuthRepositoryImpl repository;
  late MockDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  test('login returns UserEntity', () async {
    final user = MockUser();

    when(() => user.uid).thenReturn('123');
    when(() => user.email).thenReturn('test@test.com');

    when(() => mockDataSource.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => user);

    final result = await repository.login(
      email: 'test@test.com',
      password: '123456',
    );

    expect(result.uid, '123');
    expect(result.email, 'test@test.com');
  });
}