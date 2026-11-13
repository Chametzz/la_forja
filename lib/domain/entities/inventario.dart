import 'package:decimal/decimal.dart';

class Inventario {
  final int productoId;
  final int almacenId;
  final Decimal cantidad;

  Inventario({
    required this.productoId,
    required this.almacenId,
    required this.cantidad,
  });

  Inventario copyWith({int? productoId, int? almacenId, Decimal? cantidad}) {
    return Inventario(
      productoId: productoId ?? this.productoId,
      almacenId: almacenId ?? this.almacenId,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}
