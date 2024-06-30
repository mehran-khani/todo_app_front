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

class Failure extends AuthenticationState {
  final String error;

  const Failure(this.error);

  @override
  List<Object> get props => [error];
}
