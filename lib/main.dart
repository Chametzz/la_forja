import 'package:la_forja/container.dart';
import 'package:la_forja/presentation/themes/app_theme.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Forja',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: buildLoginPage(),
    );
  }
}
