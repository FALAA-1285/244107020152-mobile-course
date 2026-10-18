import '../../../../core/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl();

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      return (
        session: null,
        failure: const AuthFailure('Email atau kata sandi tidak valid'),
      );
    }
    return (
      session: AuthSession(
        access: 'mock-access-for-',
        refresh: 'mock-refresh-for-',
      ),
      failure: null,
    );
  }

  @override
  Future<({String? renewedToken, Failure? failure})> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) {
      return (
        renewedToken: null,
        failure: const AuthFailure('Refresh token hilang'),
      );
    }
    return (
      renewedToken: 'mock-access-renewed-',
      failure: null,
    );
  }
}
