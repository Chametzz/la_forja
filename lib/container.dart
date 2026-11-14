import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la_forja/data/services/user_service_impl.dart';
import 'package:la_forja/data/services/app_settings_service_impl.dart';
import 'package:la_forja/domain/entities/user.dart';
import 'package:la_forja/pkg/mysql_manager.dart';
import 'package:la_forja/presentation/states/app_settings_cubit.dart';
import 'package:la_forja/presentation/states/auth_cubit.dart';
import 'package:la_forja/presentation/states/dashboard_cubit.dart';
import 'package:la_forja/presentation/views/pages/app_settings_page.dart';
import 'package:la_forja/presentation/views/pages/dashboard_page.dart';
import 'package:la_forja/presentation/views/pages/login_page.dart';
import 'package:material_ui/material_ui.dart';

late final MySQLManager mySQLManager;
late final UserServiceImpl userService;
late final AppSettingsServiceImpl appSettingsService;

void setup() {
  mySQLManager = MySQLManager();

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
