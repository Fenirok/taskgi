import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:taskgi/features/auth/domain/usecases/login_usecase.dart';
import 'package:taskgi/features/auth/domain/usecases/signup_usecase.dart';
import 'package:taskgi/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskgi/features/auth/domain/entities/user_entity.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockSignupUseCase extends Mock implements SignupUseCase {}

void main() {
  late AuthNotifier notifier;
  late MockLoginUseCase mockLogin;
  late MockSignupUseCase mockSignup;

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockSignup = MockSignupUseCase();

    notifier = AuthNotifier(
      loginUseCase: mockLogin,
      signupUseCase: mockSignup,
    );
  });

  test('login success updates state with user', () async {
    const user = UserEntity(uid: '1', email: 'test@test.com');

    when(() => mockLogin(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => user);

    await notifier.login('test@test.com', '123456');

    expect(notifier.state.user, user);
    expect(notifier.state.isLoading, false);
  });

  test('login failure sets error', () async {
    when(() => mockLogin(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenThrow(Exception('error'));

    await notifier.login('a', 'b');

    expect(notifier.state.error, isNotNull);
  });
}