import 'package:la_forja/domain/repositories/base_repository.dart';
import 'package:la_forja/pkg/mysql_manager.dart';
import 'package:mysql_client/mysql_client.dart';

abstract class BaseMySQLRepository<E, ID> implements BaseRepository<E, ID> {
  final MySQLManager _mySQLManager;

  BaseMySQLRepository(this._mySQLManager);

  MySQLConnection get connection => _mySQLManager.connection;

  String get tableName;

  List<String> get autoIncrementFields;

  E map2Entity(Map<String, dynamic> map);
  Map<String, dynamic> entity2Map(E entity);

  ID getIdFromEntity(E entity);
  Map<String, dynamic> id2Map(ID id);

  String _where(Map<String, dynamic> params) =>
      params.keys.map((key) => "$key = :$key").join(" AND ");

  @override
  Future<List<E>> getAll({int? limit, int? offset, String? orderBy}) async {
    final query = StringBuffer("SELECT * FROM $tableName");

    if (orderBy != null && orderBy.isNotEmpty) {
      query.write(" ORDER BY $orderBy");
    }
    if (limit != null) query.write(" LIMIT $limit");
    if (offset != null) query.write(" OFFSET $offset");
    query.write(";");

    final result = await connection.execute(query.toString());
    return result.rows.map((row) => map2Entity(row.assoc())).toList();
  }

  @override
  Future<E?> getById(ID id) async {
    final params = id2Map(id);
    final result = await connection.execute(
      "SELECT * FROM $tableName WHERE ${_where(params)};",
      params,
    );

    return result.rows.isEmpty ? null : map2Entity(result.rows.first.assoc());
  }

  @override
  Future<void> delete(ID id) async {
    final params = id2Map(id);
    await connection.execute(
      "DELETE FROM $tableName WHERE ${_where(params)};",
      params,
    );
  }

  @override
  Future<E> create(E entity) async {
    final data = entity2Map(entity);

    for (var field in autoIncrementFields) {
      data.remove(field);
    }

    final columns = data.keys.join(', ');
    final placeholders = data.keys.map((k) => ':$k').join(', ');

    final result = await connection.execute(
      "INSERT INTO $tableName ($columns) VALUES ($placeholders);",
      data,
    );

    if (autoIncrementFields.isNotEmpty) {
      final generatedId = int.parse(result.lastInsertID.toString()) as ID;
      return await getById(generatedId) ?? entity;
    }

    return entity;
  }

  @override
  Future<void> update(E entity) async {
    final data = entity2Map(entity);
    final idParams = id2Map(getIdFromEntity(entity));
    final pkFields = idParams.keys.toSet();

    final setClause = data.keys
        .where((k) => !pkFields.contains(k))
        .map((k) => "$k = :$k")
        .join(', ');

    final queryParams = {...data, ...idParams};

    await connection.execute(
      "UPDATE $tableName SET $setClause WHERE ${_where(idParams)};",
      queryParams,
    );
  }
}
