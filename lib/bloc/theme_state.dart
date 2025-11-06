part of 'theme_bloc.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final bool isLight;

  const ThemeLoaded({required this.isLight});

  bool get isDark => !isLight;

  @override
  List<Object?> get props => [isLight];
}

