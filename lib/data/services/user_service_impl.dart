import 'package:la_forja/domain/entities/user.dart';
import 'package:la_forja/domain/services/app_settings_service.dart';
import 'package:la_forja/domain/services/user_service.dart';
import 'package:la_forja/pkg/mysql_manager.dart';

class UserServiceImpl implements UserService {
  final MySQLManager _mySQLManager;
  final AppSettingsService _appSettingsService;

  UserServiceImpl({
    required this._mySQLManager,
    required this._appSettingsService,
  });

  @override
  Future<User?> authenticate(String username, String password) async {
    final appSettings = await _appSettingsService.get();
    try {
      _mySQLManager.host = appSettings.host;
      _mySQLManager.port = appSettings.port;
      _mySQLManager.userName = username;
      _mySQLManager.password = password;
      await _mySQLManager.connect();
      return User(username: username, password: password);
    } catch (e) {
      return null;
    }
  }
}
