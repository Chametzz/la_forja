import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la_forja/presentation/states/app_settings_cubit.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final currentSettings = context.read<AppSettingsCubit>().state.settings;
    _hostController = TextEditingController(text: currentSettings.host);
    _portController = TextEditingController(
      text: currentSettings.port.toString(),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final host = _hostController.text.trim();
      final port = int.tryParse(_portController.text.trim()) ?? 3306;
      context.read<AppSettingsCubit>().save(host, port);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      body: BlocConsumer<AppSettingsCubit, AppSettingsState>(
        listener: (context, state) {
          if (state.isSavedSuccessfully) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Configuración guardada'),
                  backgroundColor: colorScheme.primaryContainer,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage!,
                    style: TextStyle(color: colorScheme.onError),
                  ),
                  backgroundColor: colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight -
                        48, // Resta el padding vertical del scroll
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Sección 1: Base de Datos / Red
                            _SettingsSection(
                              title: 'Base de Datos',
                              subtitle:
                                  'Parámetros de conexión al servidor MySQL',
                              icon: Icons.storage_outlined,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth > 500;
                                  final hostField = TextFormField(
                                    controller: _hostController,
                                    enabled: !state.isSaving,
                                    decoration: const InputDecoration(
                                      labelText: 'Host / Dirección IP',
                                      hintText: '127.0.0.1',
                                      prefixIcon: Icon(Icons.dns_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Requerido';
                                      }
                                      return null;
                                    },
                                  );

                                  final portField = TextFormField(
                                    controller: _portController,
                                    enabled: !state.isSaving,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Puerto',
                                      hintText: '3306',
                                      prefixIcon: Icon(Icons.lan_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          int.tryParse(value) == null) {
                                        return 'Inválido';
                                      }
                                      return null;
                                    },
                                  );

                                  if (isWide) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(flex: 3, child: hostField),
                                        const SizedBox(width: 16),
                                        Expanded(flex: 1, child: portField),
                                      ],
                                    );
                                  }

                                  return Column(
                                    children: [
                                      hostField,
                                      const SizedBox(height: 16),
                                      portField,
                                    ],
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Barra de acción alineada a la derecha en desktop / full en móvil
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 500;
                                return Align(
                                  alignment: isWide
                                      ? Alignment.centerRight
                                      : Alignment.center,
                                  child: SizedBox(
                                    width: isWide ? 200 : double.infinity,
                                    height: 44,
                                    child: FilledButton.icon(
                                      onPressed: state.isSaving
                                          ? null
                                          : () => _onSave(context),
                                      icon: state.isSaving
                                          ? SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: colorScheme.onPrimary,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.save_outlined,
                                              size: 20,
                                            ),
                                      label: Text(
                                        state.isSaving
                                            ? 'Guardando...'
                                            : 'Guardar',
                                        style: textTheme.labelLarge?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
