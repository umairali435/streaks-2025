import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaks/services/theme_service.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
    
    // Load theme on initialization
    add(LoadTheme());
  }

  Future<void> _onLoadTheme(
    LoadTheme event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final isLight = await ThemeService.isLightTheme();
      emit(ThemeLoaded(isLight: isLight));
    } catch (e) {
      emit(ThemeLoaded(isLight: false)); // Default to dark on error
    }
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final newTheme = await ThemeService.toggleTheme();
      emit(ThemeLoaded(isLight: newTheme == 'light'));
    } catch (e) {
      // Keep current state on error
    }
  }

  Future<void> _onSetTheme(
    SetTheme event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      await ThemeService.setTheme(event.isLight ? 'light' : 'dark');
      emit(ThemeLoaded(isLight: event.isLight));
    } catch (e) {
      // Keep current state on error
    }
  }
}

