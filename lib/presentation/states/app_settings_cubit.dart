import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la_forja/domain/services/app_settings_service.dart';
import 'package:la_forja/domain/value_objects/app_settings.dart';

class AppSettingsState {
  final AppSettings settings;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool isSavedSuccessfully;

  const AppSettingsState({
    required this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.isSavedSuccessfully = false,
  });

  AppSettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? isSavedSuccessfully,
  }) {
    return AppSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      isSavedSuccessfully: isSavedSuccessfully ?? false,
    );
  }
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final AppSettingsService _service;

  AppSettingsCubit({required this._service})
    : super(
        const AppSettingsState(
          settings: AppSettings(host: '127.0.0.1', port: 3306),
        ),
      ) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final settings = await _service.get();
      emit(state.copyWith(settings: settings, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> save(String host, int port) async {
    emit(
      state.copyWith(
        isSaving: true,
        errorMessage: null,
        isSavedSuccessfully: false,
      ),
    );
    try {
      final newSettings = AppSettings(host: host, port: port);
      await _service.save(newSettings);
      emit(
        state.copyWith(
          settings: newSettings,
          isSaving: false,
          isSavedSuccessfully: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }
}
