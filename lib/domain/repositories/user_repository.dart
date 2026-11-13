import 'package:la_forja/domain/entities/user.dart';

abstract class UserRepository {
  Future<User?> authenticate(String username, String password);
}
