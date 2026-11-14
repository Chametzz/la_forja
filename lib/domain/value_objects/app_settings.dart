class AppSettings {
  final String host;
  final int port;
  const AppSettings({required this.host, required this.port});

  AppSettings copyWith({String? host, int? port}) =>
      AppSettings(host: host ?? this.host, port: port ?? this.port);
}
