import 'package:get_it/get_it.dart';
import 'package:la_forja/data/repositories/user_repository_impl.dart';
import 'package:la_forja/domain/repositories/user_repository.dart';
import 'package:la_forja/pkg/mysql_manager.dart';
import 'package:la_forja/presentation/states/auth_cubit.dart';

final sl = GetIt.instance;

void setup() {
  final mySQLManager = MySQLManager();

  sl.registerFactory(() => AuthCubit(userRepository: sl()));

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(mySQLManager: mySQLManager),
  );
}
