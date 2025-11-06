import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaks/bloc/leaderboard_event.dart';
import 'package:streaks/bloc/leaderboard_state.dart';
import 'package:streaks/services/auth_service.dart';
import 'package:streaks/services/leaderboard_service.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc() : super(const LeaderboardState()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignInWithApple>(_onSignInWithApple);
    on<SignOut>(_onSignOut);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
    on<UploadUserData>(_onUploadUserData);
    on<CheckAuthStatus>(_onCheckAuthStatus);

    // Dispatch event to check auth status instead of calling method directly
    add(const CheckAuthStatus());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<LeaderboardState> emit,
  ) async {
    final user = AuthService.currentUser;
    if (user != null) {
      emit(state.copyWith(
        isSignedIn: true,
        user: user,
      ));

      add(const LoadLeaderboard());
      add(const UploadUserData());
    }
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (!AuthService.isSignedIn) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final leaderboard = await LeaderboardService.fetchLeaderboard();
      final currentUserRank = await LeaderboardService.getCurrentUserRank();

      emit(state.copyWith(
        isLoading: false,
        leaderboard: leaderboard,
        currentUserRank: currentUserRank,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load leaderboard: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final userCredential = await AuthService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        await LeaderboardService.uploadUserData();

        add(const LoadLeaderboard());

        emit(state.copyWith(
          isLoading: false,
          isSignedIn: true,
          user: userCredential.user,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Sign in cancelled',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to sign in with Google: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSignInWithApple(
    SignInWithApple event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (!Platform.isIOS) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Apple Sign In is only available on iOS',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final userCredential = await AuthService.signInWithApple();

      if (userCredential != null && userCredential.user != null) {
        await LeaderboardService.uploadUserData();

        add(const LoadLeaderboard());

        emit(state.copyWith(
          isLoading: false,
          isSignedIn: true,
          user: userCredential.user,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Sign in cancelled',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to sign in with Apple: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSignOut(
    SignOut event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await AuthService.signOut();

      emit(state.copyWith(
        isLoading: false,
        isSignedIn: false,
        user: null,
        leaderboard: [],
        currentUserRank: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to sign out: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (!AuthService.isSignedIn) {
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      await LeaderboardService.forceSync();

      final leaderboard = await LeaderboardService.fetchLeaderboard();
      final currentUserRank = await LeaderboardService.getCurrentUserRank();

      emit(state.copyWith(
        isLoading: false,
        leaderboard: leaderboard,
        currentUserRank: currentUserRank,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to refresh leaderboard: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUploadUserData(
    UploadUserData event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (!AuthService.isSignedIn) {
      return;
    }

    try {
      await LeaderboardService.uploadUserData();
    } catch (e) {
      debugPrint('Error uploading user data: $e');
    }
  }
}
