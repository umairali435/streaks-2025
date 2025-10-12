import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar_community/isar.dart';
import 'package:streaks/database/streaks_database.dart';

part 'streaks_event.dart';
part 'streaks_state.dart';

class StreaksBloc extends Bloc<StreaksEvent, StreaksState> {
  StreaksBloc() : super(StreaksInitial()) {
    on<LoadStreaks>(_onLoadStreaks);
    on<AddStreak>(_onAddStreak);
    on<UpdateStreak>(_onUpdateStreak);
    on<DeleteStreak>(_onDeleteStreak);
    on<AddStreakDate>(_onAddStreakDate);
  }

  Future<void> _onLoadStreaks(
      LoadStreaks event, Emitter<StreaksState> emit) async {
    emit(StreaksLoading());
    try {
      final streaks = await StreaksDatabase.getAllStreaks();
      emit(StreaksUpdated(streaks));
    } catch (e) {
      emit(StreaksError(e.toString()));
    }
  }

  Future<void> _onAddStreak(AddStreak event, Emitter<StreaksState> emit) async {
    try {
      await StreaksDatabase.addStreak(event.streak);
      add(LoadStreaks());
    } catch (e) {
      emit(StreaksError(e.toString()));
    }
  }

  Future<void> _onUpdateStreak(
      UpdateStreak event, Emitter<StreaksState> emit) async {
    try {
      await StreaksDatabase.addStreak(event.streak);
      add(LoadStreaks());
    } catch (e) {
      emit(StreaksError(e.toString()));
    }
  }

  Future<void> _onDeleteStreak(
      DeleteStreak event, Emitter<StreaksState> emit) async {
    try {
      await StreaksDatabase.deleteStreakById(event.id);
      add(LoadStreaks());
    } catch (e) {
      emit(StreaksError(e.toString()));
    }
  }

  Future<void> _onAddStreakDate(
      AddStreakDate event, Emitter<StreaksState> emit) async {
    try {
      await StreaksDatabase.addStreakDate(event.id, event.date);
      add(LoadStreaks());
    } catch (e) {
      emit(StreaksError(e.toString()));
    }
  }
}
