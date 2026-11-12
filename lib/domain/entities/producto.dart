class Producto {
  final int productoId;
  final String nombreProducto;
  final String codigoBarras;
  final String descripcion;
  final String categoria;
  final String marca;

  Producto({
    required this.productoId,
    required this.nombreProducto,
    required this.codigoBarras,
    required this.descripcion,
    required this.categoria,
    required this.marca,
  });

  Producto copyWith({
    int? productoId,
    String? nombreProducto,
    String? codigoBarras,
    String? descripcion,
    String? categoria,
    String? marca,
  }) {
    return Producto(
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      marca: marca ?? this.marca,
    );
  }
}
