part of 'authentication_cubit.dart';

sealed class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

final class AuthenticationInitial extends AuthenticationState {}

class Loading extends AuthenticationState {}

class LoggedOut extends AuthenticationState {}

class Success extends AuthenticationState {
  final String message;

  const Success(this.message);

  @override
  List<Object> get props => [message];
}

class Authenticated extends Success {
  final UserModel user;

  const Authenticated(super.message, this.user);

  @override
  List<Object> get props => [message, user];
}

class Failure extends AuthenticationState {
  final String error;

  const Failure(this.error);

  @override
  List<Object> get props => [error];
}
