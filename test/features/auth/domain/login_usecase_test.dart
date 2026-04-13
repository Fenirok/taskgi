import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:taskgi/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskgi/features/auth/domain/usecases/login_usecase.dart';
import 'package:taskgi/features/auth/domain/entities/user_entity.dart';

class MockRepo extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockRepo mockRepo;

  setUp(() {
    mockRepo = MockRepo();
    usecase = LoginUseCase(mockRepo);
  });

  test('calls repository.login', () async {
    const user = UserEntity(uid: '1', email: 'a@test.com');

    when(() => mockRepo.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => user);

    final result = await usecase(
      email: 'a@test.com',
      password: '123456',
    );

    expect(result, user);
  });
}