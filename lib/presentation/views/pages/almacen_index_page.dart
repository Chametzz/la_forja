import 'package:la_forja/presentation/states/almacen_index_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlmacenIndexPage extends StatefulWidget {
  const AlmacenIndexPage({super.key});

  @override
  State<AlmacenIndexPage> createState() => _AlmacenIndexPageState();
}

class _AlmacenIndexPageState extends State<AlmacenIndexPage> {
  final _valueController = TextEditingController();
  String _selectedField = 'almacen_nombre';

  final _tableHorizontalController = ScrollController();
  final _tableVerticalController = ScrollController();

  static const Map<String, String> _fieldOptions = {
    'almacen_id': 'ID',
    'almacen_nombre': 'Nombre',
    'tipo': 'Tipo',
  };

  @override
  void initState() {
    super.initState();
    // La página dispara su carga al montarse. Con el IndexedStack perezoso
    // del Dashboard, esto solo ocurre la primera vez que el usuario visita
    // "Almacenes" → no se cargan datos de otros módulos al iniciar sesión.
    context.read<AlmacenIndexCubit>().loadAll();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _tableHorizontalController.dispose();
    _tableVerticalController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final value = _valueController.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Ingresa un valor para consultar'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AlmacenIndexCubit>().search(_selectedField, value);
  }

  void _onShowAll() {
    _valueController.clear();
    FocusScope.of(context).unfocus();
    context.read<AlmacenIndexCubit>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocConsumer<AlmacenIndexCubit, AlmacenIndexState>(
        listenWhen: (prev, next) => prev.status != next.status,
        listener: (context, state) {
          if (state.status == AlmacenIndexStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? 'Error al consultar',
                    style: TextStyle(color: colorScheme.onError),
                  ),
                  backgroundColor: colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 12 : 20,
                  vertical: isCompact ? 16 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FilterSection(
                      fieldOptions: _fieldOptions,
                      selectedField: _selectedField,
                      valueController: _valueController,
                      onFieldChanged: (v) => setState(() => _selectedField = v),
                      onSearch: _onSearch,
                      onShowAll: _onShowAll,
                      isLoading: state.status == AlmacenIndexStatus.loading,
                      activeFilterLabel: state.hasFilter
                          ? '${_fieldOptions[state.searchField] ?? state.searchField}'
                                ' = ${state.searchValue}'
                          : null,
                    ),
                    SizedBox(height: isCompact ? 12 : 20),
                    Expanded(child: _buildResults(context, state)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildResults(BuildContext context, AlmacenIndexState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: switch (state.status) {
        AlmacenIndexStatus.initial || AlmacenIndexStatus.loading => Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
        AlmacenIndexStatus.failure => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.errorMessage ?? 'Error al cargar datos',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        AlmacenIndexStatus.success => Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _buildTable(context, state)),
                  if (state.items.isEmpty)
                    Positioned.fill(
                      child: Center(child: _buildEmptyMessage(context, state)),
                    ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            _buildPagination(context, state),
          ],
        ),
      },
    );
  }

  Widget _buildTable(BuildContext context, AlmacenIndexState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        return Scrollbar(
          controller: _tableVerticalController,
          thumbVisibility: !isCompact,
          child: SingleChildScrollView(
            controller: _tableVerticalController,
            child: Scrollbar(
              controller: _tableHorizontalController,
              thumbVisibility: !isCompact,
              notificationPredicate: (n) => n.depth == 1,
              child: SingleChildScrollView(
                controller: _tableHorizontalController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(
                      colorScheme.surfaceContainerHighest,
                    ),
                    horizontalMargin: isCompact ? 12 : 24,
                    columnSpacing: isCompact ? 24 : 56,
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Tipo')),
                    ],
                    rows: state.items
                        .map(
                          (a) => DataRow(
                            cells: [
                              DataCell(Text('${a.almacenId}')),
                              DataCell(Text(a.almacenNombre)),
                              DataCell(Text(a.tipo)),
                            ],
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyMessage(BuildContext context, AlmacenIndexState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            state.hasFilter
                ? 'Sin resultados para el filtro aplicado'
                : 'Aún no hay almacenes registrados',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (state.hasFilter) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _onShowAll,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Limpiar filtro'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, AlmacenIndexState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<AlmacenIndexCubit>();

    final currentPage = state.totalItems == 0 ? 0 : state.page + 1;
    final totalPages = state.totalPages;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 380;

        final pageInfo = Text(
          'Página $currentPage de ${totalPages == 0 ? 1 : totalPages}'
          '  •  ${state.totalItems} registro(s)',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: isNarrow ? TextAlign.center : TextAlign.start,
        );

        final buttons = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Anterior',
              onPressed: state.hasPrevious ? cubit.previousPage : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Siguiente',
              onPressed: state.hasNext ? cubit.nextPage : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        );

        if (isNarrow) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [pageInfo, const SizedBox(height: 4), buttons],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(child: pageInfo),
              buttons,
            ],
          ),
        );
      },
    );
  }
}

class _FilterSection extends StatelessWidget {
  final Map<String, String> fieldOptions;
  final String selectedField;
  final TextEditingController valueController;
  final ValueChanged<String> onFieldChanged;
  final VoidCallback onSearch;
  final VoidCallback onShowAll;
  final bool isLoading;
  final String? activeFilterLabel;

  const _FilterSection({
    required this.fieldOptions,
    required this.selectedField,
    required this.valueController,
    required this.onFieldChanged,
    required this.onSearch,
    required this.onShowAll,
    required this.isLoading,
    this.activeFilterLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildControls(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final iconTitle = Row(
      children: [
        Icon(Icons.filter_alt_outlined, size: 22, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtro de búsqueda',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Selecciona un campo y consulta por valor exacto',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (activeFilterLabel == null) return iconTitle;

    final chip = Chip(
      avatar: Icon(
        Icons.filter_alt,
        size: 18,
        color: colorScheme.onPrimaryContainer,
      ),
      label: Text(activeFilterLabel!),
      backgroundColor: colorScheme.primaryContainer,
      labelStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onPrimaryContainer,
      ),
      onDeleted: onShowAll,
      deleteIcon: Icon(
        Icons.close,
        size: 18,
        color: colorScheme.onPrimaryContainer,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [iconTitle, const SizedBox(height: 12), chip],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: iconTitle),
            const SizedBox(width: 12),
            chip,
          ],
        );
      },
    );
  }

  Widget _buildControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final fieldSelector = DropdownButtonFormField<String>(
      initialValue: selectedField,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Campo',
        prefixIcon: Icon(Icons.view_column_outlined),
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: fieldOptions.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: (v) {
        if (v != null) onFieldChanged(v);
      },
    );

    final valueField = TextFormField(
      controller: valueController,
      enabled: !isLoading,
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (_) => onSearch(),
      decoration: const InputDecoration(
        labelText: 'Valor',
        hintText: 'Escribe el valor a buscar',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );

    final searchButton = FilledButton.icon(
      onPressed: isLoading ? null : onSearch,
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.search),
      label: const Text('Consultar'),
    );

    final showAllButton = OutlinedButton.icon(
      onPressed: isLoading ? null : onShowAll,
      icon: const Icon(Icons.list_alt),
      label: const Text('Ver todos'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldSelector,
              const SizedBox(height: 12),
              valueField,
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Expanded(child: searchButton),
                    const SizedBox(width: 12),
                    Expanded(child: showAllButton),
                  ],
                ),
              ),
            ],
          );
        }

        if (width < 1000) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: fieldSelector),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: valueField),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Expanded(child: searchButton),
                    const SizedBox(width: 12),
                    Expanded(child: showAllButton),
                  ],
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 2, child: fieldSelector),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: valueField),
            const SizedBox(width: 12),
            SizedBox(width: 160, height: 56, child: searchButton),
            const SizedBox(width: 12),
            SizedBox(width: 160, height: 56, child: showAllButton),
          ],
        );
      },
    );
  }
}
