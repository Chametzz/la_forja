import 'package:la_forja/domain/repositories/base_repository.dart';
import 'package:la_forja/pkg/my_sql_manager.dart';
import 'package:mysql_client/mysql_client.dart';

abstract class BaseMySQLRepository<E, ID> implements BaseRepository<E, ID> {
  final MySQLManager _mySQLManager;

  BaseMySQLRepository(this._mySQLManager);

  MySQLConnection get db => _mySQLManager.connection;

  String get tableName;
  String get primaryKeyField;

  E map2Entity(Map<String, dynamic> value);
  Map<String, dynamic> entity2Map(E entity);

  ID entity2Id(E entity);
  Map<String, dynamic> id2Map(ID id);

  // Helpers
  String _buildWhereClause(Map<String, dynamic> params) {
    return params.keys.map((key) => "$key = :$key").join(" AND ");
  }

  @override
  Future<List<E>> getAll() async {
    final result = await db.execute("SELECT * FROM $tableName;");
    return result.rows.map((row) => map2Entity(row.assoc())).toList();
  }

  @override
  Future<E?> getById(ID id) async {
    final params = id2Map(id);
    final where = _buildWhereClause(params);

    final result = await db.execute(
      "SELECT * FROM $tableName WHERE $where;",
      params,
    );

    if (result.rows.isEmpty) return null;
    return map2Entity(result.rows.first.assoc());
  }

  @override
  Future<void> delete(ID id) async {
    final params = id2Map(id);
    final where = _buildWhereClause(params);

    await db.execute("DELETE FROM $tableName WHERE $where;", params);
  }

  @override
  Future<void> create(E entity) async {
    final data = entity2Map(entity);

    final columns = data.keys.join(', ');
    final placeholders = data.keys.map((k) => ':$k').join(', ');

    await db.execute(
      "INSERT INTO $tableName ($columns) VALUES ($placeholders);",
      data,
    );
  }

  @override
  Future<void> update(E entity) async {
    final data = entity2Map(entity);

    final setClause = data.keys
        .where((k) => !primaryKeyField.contains(k))
        .map((k) => "$k = :$k")
        .join(', ');

    final idParams = id2Map(entity2Id(entity));
    final where = _buildWhereClause(idParams);

    final queryParams = {...data, ...idParams};

    await db.execute(
      "UPDATE $tableName SET $setClause WHERE $where;",
      queryParams,
    );
  }
}
