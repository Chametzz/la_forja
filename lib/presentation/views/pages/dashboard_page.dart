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

  /// Vistas ya construidas, cacheadas por índice. Índices no visitados
  /// no aparecen aquí → `SizedBox.shrink()` en el stack. Una vez visitado
  /// un módulo, su widget (y su cubit / estado) viven hasta cerrar el
  /// dashboard. Los `..loadAll()` (o `initState → loadAll`) NO se ejecutan
  /// hasta que el módulo se construye por primera vez.
  final Map<int, Widget> _builtViews = {};

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
          DashboardModule(
            title: 'Almacenes',
            icon: Icons.warehouse_outlined,
            viewBuilder: (context) => buildAlmacenIndexPage(),
          ),
          DashboardModule(
            title: 'Clientes',
            icon: Icons.people_outline,
            viewBuilder: (context) => buildClienteIndexPage(),
          ),
          DashboardModule(
            title: 'Compras',
            icon: Icons.shopping_cart_outlined,
            viewBuilder: (context) => buildCompraIndexPage(),
          ),
          DashboardModule(
            title: 'Empleados',
            icon: Icons.badge_outlined,
            viewBuilder: (context) => buildEmpleadoIndexPage(),
          ),
          DashboardModule(
            title: 'Inventarios',
            icon: Icons.inventory_2_outlined,
            viewBuilder: (context) => buildInventarioIndexPage(),
          ),
          DashboardModule(
            title: 'Productos',
            icon: Icons.inventory_outlined,
            viewBuilder: (context) => buildProductoIndexPage(),
          ),
          DashboardModule(
            title: 'Proveedores',
            icon: Icons.local_shipping_outlined,
            viewBuilder: (context) => buildProveedorIndexPage(),
          ),
        ];

        final currentModule = modules[_selectedIndex];

        // ← Construye solo si aún no se había construido este índice.
        _builtViews[_selectedIndex] ??= currentModule.viewBuilder(context);

        final drawerContent = Drawer(
          backgroundColor: colorScheme.surface,
          child: SafeArea(
            bottom: false,
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
                      final module = modules[index];
                      return _buildDrawerItem(
                        context,
                        index: index,
                        icon: module.icon,
                        title: module.title,
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Icon(Icons.logout, color: colorScheme.error),
                    title: Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => buildLoginPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
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
                  // ← Children construidos desde el caché. Lo no visitado
                  //   es un SizedBox.shrink() → no monta su cubit.
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: List.generate(
                      modules.length,
                      (i) => _builtViews[i] ?? const SizedBox.shrink(),
                    ),
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: () {
          setState(() => _selectedIndex = index);
          if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
