class Proveedor {
  final String proveedorRfc;
  final String proveedorNombre;

  Proveedor({required this.proveedorRfc, required this.proveedorNombre});

  Proveedor copyWith({String? proveedorRfc, String? proveedorNombre}) {
    return Proveedor(
      proveedorRfc: proveedorRfc ?? this.proveedorRfc,
      proveedorNombre: proveedorNombre ?? this.proveedorNombre,
    );
  }
}
