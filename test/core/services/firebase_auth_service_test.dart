import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:taskgi/core/services/firebase_auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late FirebaseAuthService service;
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    service = FirebaseAuthService(firebaseAuth: mockAuth);
  });

  group('login', () {
    test('returns UserCredential on success', () async {
      final credential = MockUserCredential();

      when(() => mockAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => credential);

      final result = await service.login(
        email: 'test@test.com',
        password: '123456',
      );

      expect(result, credential);
    });

    test('throws mapped exception on FirebaseAuthException', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expect(
            () => service.login(email: 'a', password: 'b'),
        throwsA(isA<Exception>()),
      );
    });
  });
}