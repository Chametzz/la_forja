class Compra {
  final String proveedorRfc;
  final int productoId;
  final DateTime fechaOrden;
  final int cantidad;
  final DateTime fechaRecepcion;
  final int precioCompra;

  Compra({
    required this.proveedorRfc,
    required this.productoId,
    required this.fechaOrden,
    required this.cantidad,
    required this.fechaRecepcion,
    required this.precioCompra,
  });

  Compra copyWith({
    String? proveedorRfc,
    int? productoId,
    DateTime? fechaOrden,
    int? cantidad,
    DateTime? fechaRecepcion,
    int? precioCompra,
  }) {
    return Compra(
      proveedorRfc: proveedorRfc ?? this.proveedorRfc,
      productoId: productoId ?? this.productoId,
      fechaOrden: fechaOrden ?? this.fechaOrden,
      cantidad: cantidad ?? this.cantidad,
      fechaRecepcion: fechaRecepcion ?? this.fechaRecepcion,
      precioCompra: precioCompra ?? this.precioCompra,
    );
  }
}
