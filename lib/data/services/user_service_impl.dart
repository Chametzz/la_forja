import 'package:la_forja/domain/entities/user.dart';
import 'package:la_forja/domain/services/app_settings_service.dart';
import 'package:la_forja/domain/services/user_service.dart';
import 'package:la_forja/domain/value_objects/permissions.dart';
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

      final privileges = await _getUserPrivileges();

      return User(
        username: username,
        password: password,
        almacenPermissions: _buildPermissions(privileges, 'almacenes'),
        clientePermissions: _buildPermissions(privileges, 'clientes'),
        compraPermissions: _buildPermissions(privileges, 'compras'),
        empleadoPermissions: _buildPermissions(privileges, 'empleados'),
        inventarioPermissions: _buildPermissions(privileges, 'inventarios'),
        productoPermissions: _buildPermissions(privileges, 'productos'),
        proveedorPermissions: _buildPermissions(privileges, 'proveedores'),
        ventaPermissions: _buildPermissions(privileges, 'ventas'),
      );
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('Error en authenticate: $e');
      // ignore: avoid_print
      print(stackTrace);
      return null;
    }
  }

  Future<Map<String, Set<String>>> _getUserPrivileges() async {
    const query = """
      SELECT '*' AS table_name, PRIVILEGE_TYPE AS privilege
      FROM information_schema.USER_PRIVILEGES
      WHERE GRANTEE = CONCAT('''', REPLACE(CURRENT_USER(), '@', '''@'''), '''')
        AND PRIVILEGE_TYPE IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE')
      UNION
      SELECT '*' AS table_name, PRIVILEGE_TYPE AS privilege
      FROM information_schema.SCHEMA_PRIVILEGES
      WHERE TABLE_SCHEMA = DATABASE()
        AND GRANTEE = CONCAT('''', REPLACE(CURRENT_USER(), '@', '''@'''), '''')
        AND PRIVILEGE_TYPE IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE')
      UNION
      SELECT LOWER(TABLE_NAME) AS table_name, PRIVILEGE_TYPE AS privilege
      FROM information_schema.TABLE_PRIVILEGES
      WHERE TABLE_SCHEMA = DATABASE()
        AND GRANTEE = CONCAT('''', REPLACE(CURRENT_USER(), '@', '''@'''), '''')
        AND PRIVILEGE_TYPE IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE');
    """;

    final result = await _mySQLManager.connection.execute(query);
    final privilegesByTable = <String, Set<String>>{};

    for (final row in result.rows) {
      final tableName = row.colByName('table_name')?.toLowerCase();
      final privilege = row.colByName('privilege')?.toUpperCase();
      if (tableName == null || privilege == null) continue;

      privilegesByTable.putIfAbsent(tableName, () => <String>{}).add(privilege);
    }

    return privilegesByTable;
  }

  Permissions _buildPermissions(
    Map<String, Set<String>> privilegesByTable,
    String tableName,
  ) {
    final global = privilegesByTable['*'] ?? const <String>{};
    final table = privilegesByTable[tableName] ?? const <String>{};

    bool has(String privilege) =>
        global.contains(privilege) || table.contains(privilege);

    return Permissions(
      create: has('INSERT'),
      read: has('SELECT'),
      update: has('UPDATE'),
      delete: has('DELETE'),
    );
  }
}
