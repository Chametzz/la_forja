import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la_forja/domain/entities/user.dart';

class DashboardState {
  final User user;
  DashboardState({required this.user});
}

class DashboardCubit extends Cubit<DashboardState> {
  final User user;
  DashboardCubit({required this.user}) : super(DashboardState(user: user));
}
