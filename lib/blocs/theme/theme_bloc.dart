import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kid_arena/blocs/theme/theme_event.dart';
import 'package:kid_arena/blocs/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;

  ThemeBloc() : super(const ThemeState()) {
    on<ThemeLoadRequested>(_onThemeLoadRequested);
    on<ThemeToggled>(_onThemeToggled);
  }

  Future<void> _onThemeLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    _prefs = await SharedPreferences.getInstance();
    final isDarkMode = _prefs.getBool(_themeKey) ?? false;
    emit(state.copyWith(isDarkMode: isDarkMode));
  }

  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    final newIsDarkMode = !state.isDarkMode;
    await _prefs.setBool(_themeKey, newIsDarkMode);
    emit(state.copyWith(isDarkMode: newIsDarkMode));
  }
}
