import 'package:la_forja/domain/entities/compra.dart';
import 'package:la_forja/domain/repositories/repositorio_base.dart';

abstract class CompraRepository
    implements
        BaseRepository<
          Compra,
          (String proveedorRfc, int productoId, DateTime fechaOrden)
        > {}
