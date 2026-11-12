import 'package:la_forja/domain/entities/inventario.dart';
import 'package:la_forja/domain/repositories/repositorio_base.dart';

abstract class InventarioRepository
    implements BaseRepository<Inventario, (int productoId, int almacenId)> {}
