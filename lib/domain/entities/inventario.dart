class Inventario {
  final int productoId;
  final int almacenId;
  final int cantidad;

  Inventario({
    required this.productoId,
    required this.almacenId,
    required this.cantidad,
  });

  Inventario copyWith({int? productoId, int? almacenId, int? cantidad}) {
    return Inventario(
      productoId: productoId ?? this.productoId,
      almacenId: almacenId ?? this.almacenId,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}
