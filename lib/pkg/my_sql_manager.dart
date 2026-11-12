import 'package:mysql_client/mysql_client.dart';

class MySQLManager {
  MySQLConnection? _connection;

  MySQLConnection get connection {
    if (_connection == null || !_connection!.connected) {
      throw Exception(
        "There is no active MySQL connection. Make sure to connect first.",
      );
    }

    return _connection!;
  }

  Future<void> connect({
    required String host,
    required int port,
    required String userName,
    required String password,
    required String databaseName,
  }) async {
    if (_connection != null && _connection!.connected) {
      await _connection!.close();
    }

    _connection = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: userName,
      password: password,
      databaseName: databaseName,
    );

    await _connection!.connect();
  }

  Future<void> disconnect() async {
    if (_connection != null && _connection!.connected) {
      await _connection!.close();
      _connection = null;
    }
  }
}
