class Empleado {
  final int empleadoId;
  final String empleadoNombre;
  final String empleadoApellido;
  final String rol;

  Empleado({
    required this.empleadoId,
    required this.empleadoNombre,
    required this.empleadoApellido,
    required this.rol,
  });

  Empleado copyWith({
    int? empleadoId,
    String? empleadoNombre,
    String? empleadoApellido,
    String? rol,
  }) {
    return Empleado(
      empleadoId: empleadoId ?? this.empleadoId,
      empleadoNombre: empleadoNombre ?? this.empleadoNombre,
      empleadoApellido: empleadoApellido ?? this.empleadoApellido,
      rol: rol ?? this.rol,
    );
  }
}
