part of 'streaks_bloc.dart';

abstract class StreaksState extends Equatable {
  const StreaksState();

  @override
  List<Object> get props => [];
}

class StreaksInitial extends StreaksState {}

class StreaksLoading extends StreaksState {}

class StreaksUpdated extends StreaksState {
  final List<Streak> streaks;

  const StreaksUpdated(this.streaks);

  @override
  List<Object> get props => [streaks];
}

class StreaksError extends StreaksState {
  final String message;

  const StreaksError(this.message);

  @override
  List<Object> get props => [message];
}
