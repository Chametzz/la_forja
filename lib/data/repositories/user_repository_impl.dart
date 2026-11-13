import 'package:la_forja/domain/entities/user.dart';
import 'package:la_forja/domain/repositories/user_repository.dart';
import 'package:la_forja/pkg/mysql_manager.dart';

class UserRepositoryImpl implements UserRepository {
  final MySQLManager _mySQLManager;

  UserRepositoryImpl({required this._mySQLManager});

  @override
  Future<User?> authenticate(String username, String password) async {
    try {
      _mySQLManager.userName = username;
      _mySQLManager.password = password;
      await _mySQLManager.connect();
      return User(username: username, password: password);
    } catch (e) {
      return null;
    }
  }
}
