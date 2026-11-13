import 'package:decimal/decimal.dart';
import 'package:la_forja/data/repositories/base_mysql_repository.dart';
import 'package:la_forja/domain/entities/inventario.dart';
import 'package:la_forja/domain/repositories/inventario_repository.dart';

class InventarioRepositoryImpl
    extends BaseMySQLRepository<Inventario, (int productoId, int almacenId)>
    implements InventarioRepository {
  new(super.mySQLManager);

  @override
  Map<String, dynamic> entity2Map(Inventario entity) => {
    "producto_id": entity.productoId,
    "almacen_id": entity.almacenId,
    "cantidad": entity.cantidad
        .toString(), // Convertido a String exacto para MySQL
  };

  @override
  (int, int) getIdFromEntity(Inventario entity) =>
      (entity.productoId, entity.almacenId);

  @override
  Map<String, dynamic> id2Map((int, int) id) => {
    "producto_id": id.$1,
    "almacen_id": id.$2,
  };

  @override
  Inventario map2Entity(Map<String, dynamic> map) => Inventario(
    productoId: int.parse(map["producto_id"].toString()),
    almacenId: int.parse(map["almacen_id"].toString()),
    cantidad: Decimal.parse(map["cantidad"].toString()),
  );

  @override
  String get tableName => "inventarios";

  @override
  List<String> get autoIncrementFields => [];
}
