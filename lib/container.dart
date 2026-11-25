import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la_forja/data/repositories/almacen_repository_impl.dart';
import 'package:la_forja/data/repositories/inventario_repository_impl.dart';
import 'package:la_forja/data/services/user_service_impl.dart';
import 'package:la_forja/data/services/app_settings_service_impl.dart';
import 'package:la_forja/domain/entities/user.dart';
import 'package:la_forja/domain/repositories/almacen_repository.dart';
import 'package:la_forja/domain/repositories/inventario_repository.dart';
import 'package:la_forja/pkg/mysql_manager.dart';
import 'package:la_forja/presentation/states/almacen_index_cubit.dart';
import 'package:la_forja/presentation/states/app_settings_cubit.dart';
import 'package:la_forja/presentation/states/auth_cubit.dart';
import 'package:la_forja/presentation/states/dashboard_cubit.dart';
import 'package:la_forja/presentation/states/inventario_index_cubit.dart';
import 'package:la_forja/presentation/views/pages/almacen_index_page.dart';
import 'package:la_forja/presentation/views/pages/app_settings_page.dart';
import 'package:la_forja/presentation/views/pages/dashboard_page.dart';
import 'package:la_forja/presentation/views/pages/inventario_index_page.dart';
import 'package:la_forja/presentation/views/pages/login_page.dart';
import 'package:material_ui/material_ui.dart';

late final MySQLManager mySQLManager;

late final AlmacenRepository almacenRepository;
late final InventarioRepository inventarioRepository;

late final UserServiceImpl userService;
late final AppSettingsServiceImpl appSettingsService;

void setup() {
  mySQLManager = MySQLManager();
  mySQLManager.databaseName = 'la_forja';

  almacenRepository = AlmacenRepositoryImpl(mySQLManager);
  inventarioRepository = InventarioRepositoryImpl(mySQLManager);

  appSettingsService = AppSettingsServiceImpl();
  userService = UserServiceImpl(
    mySQLManager: mySQLManager,
    appSettingsService: appSettingsService,
  );
}

Widget buildLoginPage() => BlocProvider(
  create: (context) => AuthCubit(userService: userService),
  child: const LoginPage(),
);

Widget buildDashboardPage({required User user}) => BlocProvider(
  create: (context) => DashboardCubit(user: user),
  child: const DashboardPage(),
);

Widget buildAppSettingsPage() => BlocProvider(
  create: (context) => AppSettingsCubit(service: appSettingsService),
  child: const AppSettingsPage(),
);

Widget buildAlmacenIndexPage() => BlocProvider(
  create: (context) => AlmacenIndexCubit(almacenRepository),
  child: const AlmacenIndexPage(),
);
Widget buildClienteIndexPage() => const Placeholder();
Widget buildCompraIndexPage() => const Placeholder();
Widget buildEmpleadoIndexPage() => const Placeholder();
Widget buildInventarioIndexPage() => BlocProvider(
  create: (context) => InventarioIndexCubit(inventarioRepository),
  child: const InventarioIndexPage(),
);
Widget buildProductoIndexPage() => const Placeholder();
Widget buildProveedorIndexPage() => const Placeholder();
Widget buildVentaIndexPage() => const Placeholder();
