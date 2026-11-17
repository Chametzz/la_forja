import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la_forja/domain/entities/almacen.dart';
import 'package:la_forja/domain/repositories/almacen_repository.dart';

enum AlmacenIndexStatus { initial, loading, success, failure }

class AlmacenIndexState {
  final AlmacenIndexStatus status;
  final List<Almacen> items;
  final int page; // 0-index
  final int pageSize;
  final int totalItems;
  final String? searchField;
  final String? searchValue;
  final String? errorMessage;

  const AlmacenIndexState({
    this.status = AlmacenIndexStatus.initial,
    this.items = const [],
    this.page = 0,
    this.pageSize = 10,
    this.totalItems = 0,
    this.searchField,
    this.searchValue,
    this.errorMessage,
  });

  bool get hasFilter => searchField != null && searchValue != null;
  int get totalPages => totalItems == 0 ? 0 : (totalItems / pageSize).ceil();
  bool get hasPrevious => page > 0;
  bool get hasNext => page + 1 < totalPages;

  AlmacenIndexState copyWith({
    AlmacenIndexStatus? status,
    List<Almacen>? items,
    int? page,
    int? pageSize,
    int? totalItems,
    String? searchField,
    String? searchValue,
    String? errorMessage,
    bool clearSearch = false,
  }) => AlmacenIndexState(
    status: status ?? this.status,
    items: items ?? this.items,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    totalItems: totalItems ?? this.totalItems,
    searchField: clearSearch ? null : (searchField ?? this.searchField),
    searchValue: clearSearch ? null : (searchValue ?? this.searchValue),
    errorMessage: errorMessage,
  );
}

class AlmacenIndexCubit extends Cubit<AlmacenIndexState> {
  final AlmacenRepository _repository;

  AlmacenIndexCubit(this._repository) : super(const AlmacenIndexState());

  /// Carga inicial y "Ver todos": sin filtro, primera página.
  Future<void> loadAll() async {
    emit(
      state.copyWith(
        status: AlmacenIndexStatus.loading,
        clearSearch: true,
        page: 0,
      ),
    );
    await _fetch();
  }

  /// Consultar con filtro exacto (campo = valor).
  Future<void> search(String field, String value) async {
    emit(
      state.copyWith(
        status: AlmacenIndexStatus.loading,
        searchField: field,
        searchValue: value.trim(),
        page: 0,
      ),
    );
    await _fetch();
  }

  Future<void> goToPage(int page) async {
    if (page < 0) return;
    emit(state.copyWith(status: AlmacenIndexStatus.loading, page: page));
    await _fetch();
  }

  Future<void> nextPage() async {
    if (!state.hasNext) return;
    await goToPage(state.page + 1);
  }

  Future<void> previousPage() async {
    if (!state.hasPrevious) return;
    await goToPage(state.page - 1);
  }

  Future<void> _fetch() async {
    try {
      final items = await _repository.getAll(
        limit: state.pageSize,
        offset: state.page * state.pageSize,
        orderBy: 'almacen_id ASC',
        field: state.searchField, // null → sin filtro
        value: state.searchValue, // null → sin filtro
      );

      final total = await _repository.count(
        field: state.searchField,
        value: state.searchValue,
      );

      emit(
        state.copyWith(
          status: AlmacenIndexStatus.success,
          items: items,
          totalItems: total,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AlmacenIndexStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
