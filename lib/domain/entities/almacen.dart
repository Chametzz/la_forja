class Almacen {
  final int almacenId;
  final String almacenNombre;
  final String tipo;

  Almacen({
    required this.almacenId,
    required this.almacenNombre,
    required this.tipo,
  });

  Almacen copyWith({int? almacenId, String? almacenNombre, String? tipo}) {
    return Almacen(
      almacenId: almacenId ?? this.almacenId,
      almacenNombre: almacenNombre ?? this.almacenNombre,
      tipo: tipo ?? this.tipo,
    );
  }
}
