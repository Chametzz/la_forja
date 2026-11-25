import 'package:la_forja/domain/value_objects/permissions.dart';

class User {
  final String username;
  final String password;
  final Permissions almacenPermissions;
  final Permissions clientePermissions;
  final Permissions compraPermissions;
  final Permissions empleadoPermissions;
  final Permissions inventarioPermissions;
  final Permissions productoPermissions;
  final Permissions proveedorPermissions;
  final Permissions ventaPermissions;

  User({
    required this.username,
    required this.password,
    required this.almacenPermissions,
    required this.clientePermissions,
    required this.compraPermissions,
    required this.empleadoPermissions,
    required this.inventarioPermissions,
    required this.productoPermissions,
    required this.proveedorPermissions,
    required this.ventaPermissions,
  });

  User copyWith({
    String? username,
    String? password,
    Permissions? almacenPermissions,
    Permissions? clientePermissions,
    Permissions? compraPermissions,
    Permissions? empleadoPermissions,
    Permissions? inventarioPermissions,
    Permissions? productoPermissions,
    Permissions? proveedorPermissions,
    Permissions? ventaPermissions,
  }) {
    return User(
      username: username ?? this.username,
      password: password ?? this.password,
      almacenPermissions: almacenPermissions ?? this.almacenPermissions,
      clientePermissions: clientePermissions ?? this.clientePermissions,
      compraPermissions: compraPermissions ?? this.compraPermissions,
      empleadoPermissions: empleadoPermissions ?? this.empleadoPermissions,
      inventarioPermissions:
          inventarioPermissions ?? this.inventarioPermissions,
      productoPermissions: productoPermissions ?? this.productoPermissions,
      proveedorPermissions: proveedorPermissions ?? this.proveedorPermissions,
      ventaPermissions: ventaPermissions ?? this.ventaPermissions,
    );
  }
}
