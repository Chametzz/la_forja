import 'package:la_forja/data/repositories/base_mysql_repository.dart';
import 'package:la_forja/domain/entities/almacen.dart';
import 'package:la_forja/domain/repositories/almacen_repository.dart';

class AlmacenRepositoryImpl extends BaseMySQLRepository<Almacen, int>
    implements AlmacenRepository {
  new(super.mySQLManager);

  @override
  Map<String, dynamic> entity2Map(Almacen entity) => {
    "almacen_id": entity.almacenId,
    "almacen_nombre": entity.almacenNombre,
    "tipo": entity.tipo,
  };

  @override
  int getIdFromEntity(Almacen entity) => entity.almacenId;

  @override
  Map<String, dynamic> id2Map(int id) => {"almacen_id": id};

  @override
  Almacen map2Entity(Map<String, dynamic> map) => Almacen(
    almacenId: map["almacen_id"],
    almacenNombre: map["almacen_nombre"],
    tipo: map["tipo"],
  );

  @override
  String get tableName => "almacenes";

  @override
  List<String> get autoIncrementFields => ["almacen_id"];
}
