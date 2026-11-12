class Venta {
  final String folioVenta;
  final int productoId;
  final int empleadoId;
  final int clienteId;
  final DateTime fechaVenta;
  final int cantidad;
  final int precioVenta;

  Venta({
    required this.folioVenta,
    required this.productoId,
    required this.empleadoId,
    required this.clienteId,
    required this.fechaVenta,
    required this.cantidad,
    required this.precioVenta,
  });

  Venta copyWith({
    String? folioVenta,
    int? productoId,
    int? empleadoId,
    int? clienteId,
    DateTime? fechaVenta,
    int? cantidad,
    int? precioVenta,
  }) {
    return Venta(
      folioVenta: folioVenta ?? this.folioVenta,
      productoId: productoId ?? this.productoId,
      empleadoId: empleadoId ?? this.empleadoId,
      clienteId: clienteId ?? this.clienteId,
      fechaVenta: fechaVenta ?? this.fechaVenta,
      cantidad: cantidad ?? this.cantidad,
      precioVenta: precioVenta ?? this.precioVenta,
    );
  }
}
