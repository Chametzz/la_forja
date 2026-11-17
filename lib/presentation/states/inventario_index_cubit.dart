import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la_forja/domain/entities/inventario.dart';
import 'package:la_forja/domain/repositories/inventario_repository.dart';

enum InventarioIndexStatus { initial, loading, success, failure }

class InventarioIndexState {
  final InventarioIndexStatus status;
  final List<Inventario> items;
  final int page; // 0-index
  final int pageSize;
  final int totalItems;
  final String? searchField;
  final String? searchValue;
  final String? errorMessage;

  const InventarioIndexState({
    this.status = InventarioIndexStatus.initial,
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

  InventarioIndexState copyWith({
    InventarioIndexStatus? status,
    List<Inventario>? items,
    int? page,
    int? pageSize,
    int? totalItems,
    String? searchField,
    String? searchValue,
    String? errorMessage,
    bool clearSearch = false,
  }) => InventarioIndexState(
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

class InventarioIndexCubit extends Cubit<InventarioIndexState> {
  final InventarioRepository _repository;

  InventarioIndexCubit(this._repository) : super(const InventarioIndexState());

  /// Carga inicial y "Ver todos": sin filtro, primera página.
  Future<void> loadAll() async {
    emit(
      state.copyWith(
        status: InventarioIndexStatus.loading,
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
        status: InventarioIndexStatus.loading,
        searchField: field,
        searchValue: value.trim(),
        page: 0,
      ),
    );
    await _fetch();
  }

  Future<void> goToPage(int page) async {
    if (page < 0) return;
    emit(state.copyWith(status: InventarioIndexStatus.loading, page: page));
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
        orderBy: 'producto_id ASC, almacen_id ASC',
        field: state.searchField, // null → sin filtro
        value: state.searchValue, // null → sin filtro
      );

      final total = await _repository.count(
        field: state.searchField,
        value: state.searchValue,
      );

      emit(
        state.copyWith(
          status: InventarioIndexStatus.success,
          items: items,
          totalItems: total,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InventarioIndexStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
