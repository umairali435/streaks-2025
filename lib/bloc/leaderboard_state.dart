import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardState extends Equatable {
  final bool isLoading;
  final bool isSignedIn;
  final User? user;
  final List<Map<String, dynamic>> leaderboard;
  final int? currentUserRank;
  final String? error;

  const LeaderboardState({
    this.isLoading = false,
    this.isSignedIn = false,
    this.user,
    this.leaderboard = const [],
    this.currentUserRank,
    this.error,
  });

  LeaderboardState copyWith({
    bool? isLoading,
    bool? isSignedIn,
    User? user,
    List<Map<String, dynamic>>? leaderboard,
    int? currentUserRank,
    String? error,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      user: user ?? this.user,
      leaderboard: leaderboard ?? this.leaderboard,
      currentUserRank: currentUserRank ?? this.currentUserRank,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSignedIn,
        user,
        leaderboard,
        currentUserRank,
        error,
      ];
}

