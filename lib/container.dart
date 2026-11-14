import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la_forja/data/repositories/user_repository_impl.dart';
import 'package:la_forja/domain/entities/user.dart';
import 'package:la_forja/pkg/mysql_manager.dart';
import 'package:la_forja/presentation/states/auth_cubit.dart';
import 'package:la_forja/presentation/states/dashboard_cubit.dart';
import 'package:la_forja/presentation/views/pages/dashboard_page.dart';
import 'package:la_forja/presentation/views/pages/login_page.dart';
import 'package:material_ui/material_ui.dart';

late final MySQLManager mySQLManager;
late final UserRepositoryImpl userRepository;

void setup() {
  mySQLManager = MySQLManager();
  userRepository = UserRepositoryImpl(mySQLManager: mySQLManager);
}

Widget buildLoginPage() {
  return BlocProvider(
    create: (context) => AuthCubit(userRepository: userRepository),
    child: LoginPage(),
  );
}

Widget buildDashboardPage({required User user}) {
  return BlocProvider(
    create: (context) => DashboardCubit(user: user),
    child: DashboardPage(),
  );
}
