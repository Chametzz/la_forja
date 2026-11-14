import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la_forja/container.dart';
import 'package:la_forja/presentation/states/dashboard_cubit.dart';

class DashboardModule {
  final String title;
  final IconData icon;
  final WidgetBuilder viewBuilder;
  const DashboardModule({
    required this.title,
    required this.icon,
    required this.viewBuilder,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final user = state.user;

        final List<DashboardModule> modules = [
          DashboardModule(
            title: 'Inicio',
            icon: Icons.dashboard_outlined,
            viewBuilder: (context) =>
                Center(child: Text('Bienvenido al inicio, ${user.username}')),
          ),
        ];

        final currentModule = modules[_selectedIndex];

        final drawerContent = Drawer(
          backgroundColor: colorScheme.surface,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: colorScheme.primary),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: colorScheme.onPrimary,
                  child: Text(
                    user.username.isNotEmpty
                        ? user.username[0].toUpperCase()
                        : 'F',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                accountName: Text(
                  user.username,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  user.username,
                  style: TextStyle(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ),

              // Generamos los elementos del menú automáticamente
              ...List.generate(modules.length, (index) {
                final module = modules[index];
                return _buildDrawerItem(
                  context,
                  index: index,
                  icon: module.icon,
                  title: module.title,
                );
              }),

              const Spacer(),
              const Divider(),

              // Opción de Logout manual sin GoRouter
              ListTile(
                leading: Icon(Icons.logout, color: colorScheme.error),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => buildLoginPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: !isDesktop,
            title: Text(currentModule.title),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            elevation: 1,
          ),
          body: Row(
            children: [
              if (isDesktop) SizedBox(width: 280, child: drawerContent),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: modules
                        .map((m) => m.viewBuilder(context))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          drawer: isDesktop ? null : drawerContent,
        );
      },
    );
  }

  // Método auxiliar para generar los elementos del menú iluminados al seleccionarlos
  Widget _buildDrawerItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        // Si está en móvil, cerramos el drawer automáticamente al hacer clic
        if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
          Navigator.pop(context);
        }
      },
    );
  }
}
