part of 'streaks_bloc.dart';

abstract class StreaksEvent extends Equatable {
  const StreaksEvent();

  @override
  List<Object> get props => [];
}

class LoadStreaks extends StreaksEvent {}

class AddStreak extends StreaksEvent {
  final Streak streak;

  const AddStreak(this.streak);

  @override
  List<Object> get props => [streak];
}

class UpdateStreak extends StreaksEvent {
  final Streak streak;

  const UpdateStreak(this.streak);

  @override
  List<Object> get props => [streak];
}

class DeleteStreak extends StreaksEvent {
  final Id id;

  const DeleteStreak(this.id);

  @override
  List<Object> get props => [id];
}

class AddStreakDate extends StreaksEvent {
  final Id id;
  final DateTime date;

  const AddStreakDate(this.id, this.date);

  @override
  List<Object> get props => [id, date];
}
