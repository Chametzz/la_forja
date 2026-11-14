import 'dart:convert';
import 'dart:io';

import 'package:la_forja/domain/value_objects/app_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:la_forja/domain/services/app_settings_service.dart';

class AppSettingsServiceImpl implements AppSettingsService {
  static const String _filename = 'app_settings.json';

  Future<File> _resolveFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_filename');
  }

  @override
  Future<AppSettings> get() async {
    try {
      final file = await _resolveFile();
      if (!await file.exists()) {
        const defaultSettings = AppSettings(host: '127.0.0.1', port: 3306);
        await save(defaultSettings);
        return defaultSettings;
      }

      final contents = await file.readAsString();
      final data = jsonDecode(contents) as Map<String, dynamic>;

      return AppSettings(
        host: data['host'] as String? ?? '127.0.0.1',
        port: data['port'] as int? ?? 3306,
      );
    } catch (_) {
      return const AppSettings(host: '127.0.0.1', port: 3306);
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    try {
      final file = await _resolveFile();
      final data = {'host': settings.host, 'port': settings.port};
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (e) {
      rethrow;
    }
  }
}
