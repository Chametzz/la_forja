import 'package:la_forja/domain/entities/compra.dart';
import 'package:la_forja/domain/repositories/base_repository.dart';

abstract class CompraRepository
    implements
        BaseRepository<
          Compra,
          (String proveedorRfc, int productoId, DateTime fechaOrden)
        > {}
