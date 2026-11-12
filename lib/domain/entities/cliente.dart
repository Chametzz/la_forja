class Cliente {
  final int clienteId;
  final String clienteNombre;
  final String clienteApellido;

  Cliente({
    required this.clienteId,
    required this.clienteNombre,
    required this.clienteApellido,
  });

  Cliente copyWith({
    int? clienteId,
    String? clienteNombre,
    String? clienteApellido,
  }) {
    return Cliente(
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clienteApellido: clienteApellido ?? this.clienteApellido,
    );
  }
}
