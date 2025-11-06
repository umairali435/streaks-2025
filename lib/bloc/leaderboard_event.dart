import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeaderboard extends LeaderboardEvent {
  const LoadLeaderboard();
}

class SignInWithGoogle extends LeaderboardEvent {
  const SignInWithGoogle();
}

class SignInWithApple extends LeaderboardEvent {
  const SignInWithApple();
}

class SignOut extends LeaderboardEvent {
  const SignOut();
}

class RefreshLeaderboard extends LeaderboardEvent {
  const RefreshLeaderboard();
}

class UploadUserData extends LeaderboardEvent {
  const UploadUserData();
}

class CheckAuthStatus extends LeaderboardEvent {
  const CheckAuthStatus();
}

