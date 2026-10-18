import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/usecases/login_user.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldFail = false;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail || !email.contains('@') || password.length < 6) {
      return (session: null, failure: const AuthFailure('Kredensial salah'));
    }
    return (
      session: AuthSession(access: 'token-$email', refresh: 'refresh-$email'),
      failure: null,
    );
  }

  @override
  Future<({String? renewedToken, Failure? failure})> refresh(String refreshToken) async {
    if (refreshToken.isEmpty) {
      return (renewedToken: null, failure: const AuthFailure('Refresh token kosong'));
    }
    return (renewedToken: 'new-token', failure: null);
  }
}

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late LoginUser loginUser;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
    loginUser = LoginUser(fakeAuthRepository);
  });

  test('LoginUser usecase berhasil mengembalikan session saat kredensial valid', () async {
    final result = await loginUser.call(email: 'test@kampus.ac.id', password: 'password123');
    expect(result.failure, isNull);
    expect(result.session?.access, 'token-test@kampus.ac.id');
  });

  test('LoginUser usecase mengembalikan failure saat password terlalu pendek', () async {
    final result = await loginUser.call(email: 'test@kampus.ac.id', password: '123');
    expect(result.failure, isA<AuthFailure>());
    expect(result.session, isNull);
  });
}
