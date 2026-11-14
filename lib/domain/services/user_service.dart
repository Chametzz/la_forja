import 'package:la_forja/domain/entities/user.dart';

abstract class UserService {
  Future<User?> authenticate(String username, String password);
}
