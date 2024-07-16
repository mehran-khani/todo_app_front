part of 'authentication_cubit.dart';

sealed class AuthenticationState extends Equatable {
  final bool isLoading;
  final String? error;
  const AuthenticationState(this.isLoading, this.error);

  @override
  List<Object?> get props => [isLoading, error];
}

final class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial(super.isLoading, super.error);
}

class Authenticated extends AuthenticationState {
  final UserModel user;
  final String message;

  const Authenticated({
    required this.user,
    required this.message,
    required bool isLoading,
    String? error,
  }) : super(isLoading, error);

  @override
  List<Object?> get props => [user, message, isLoading, error];
}

class Registering extends AuthenticationState {
  const Registering({
    required bool isLoading,
    String? error,
  }) : super(isLoading, error);

  @override
  List<Object?> get props => [isLoading, error];
}

class Verifying extends AuthenticationState {
  const Verifying({
    required bool isLoading,
    String? error,
  }) : super(isLoading, error);

  @override
  List<Object?> get props => [isLoading, error];
}

class LoggedOut extends AuthenticationState {
  const LoggedOut({
    required bool isLoading,
    String? error,
  }) : super(isLoading, error);

  @override
  List<Object?> get props => [isLoading, error];
}

class Success extends AuthenticationState {
  final String message;

  const Success({
    required this.message,
    required bool isLoading,
    String? error,
  }) : super(isLoading, error);

  @override
  List<Object?> get props => [message, isLoading, error];
}
