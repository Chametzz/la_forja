import 'package:la_forja/domain/value_objects/app_settings.dart';

abstract class AppSettingsService {
  Future<AppSettings> get();
  Future<void> save(AppSettings settings);
}
