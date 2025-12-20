import 'package:flutter/material.dart';

/// A highly customizable and dynamic table widget for Flutter.
///
/// `WeekleeTable` provides a comprehensive table implementation with features like:
/// - Multiple column width types (flex, fixed, intrinsic, fractional)
/// - Sortable columns with custom sort indicators
/// - Expandable rows with custom expansion content
/// - Row grouping and sections
/// - Empty and loading states
/// - Hover effects and interactions
/// - Comprehensive theming system
/// - Footer rows
/// - Checkbox selection with custom builders
///
/// The table does not have its own scrolling - wrap it in a ScrollView if needed.
///
/// Example:
/// ```dart
/// WeekleeTable(
///   columns: [
///     WeekleeTableColumn(
///       header: Text('Name'),
///       width: FlexColumnWidth(2),
///       sortable: true,
///     ),
///     WeekleeTableColumn(
///       header: Text('Age'),
///       width: FixedColumnWidth(100),
///     ),
///   ],
///   rows: [
///     WeekleeTableRow(cells: [Text('Alice'), Text('25')]),
///     WeekleeTableRow(cells: [Text('Bob'), Text('30')]),
///   ],
/// )
/// ```
class WeekleeTable extends StatefulWidget {
  const WeekleeTable({
    super.key,
    required this.columns,
    this.rows = const [],
    this.theme,
    this.headerBuilder,
    this.cellBuilder,
    this.rowBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.footerRows,
    this.showCheckboxes = false,
    this.checkboxBuilder,
    this.onSelectAll,
    this.selectedRows = const {},
    this.onRowSelected,
    this.expandableRowBuilder,
    this.expandedRows = const {},
    this.onRowExpanded,
    this.isLoading = false,
    this.onSort,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.groups,
    this.groupHeaderBuilder,
    this.onRowTap,
    this.onRowDoubleTap,
    this.onRowLongPress,
    this.onCellTap,
    this.border,
    this.divider,
  });

  /// List of columns defining the table structure.
  final List<WeekleeTableColumn> columns;

  /// List of data rows to display.
  final List<WeekleeTableRow> rows;

  /// Optional theme for consistent styling across the table.
  final WeekleeTableTheme? theme;

  /// Custom builder for header cells.
  /// If provided, overrides default header rendering.
  final Widget Function(BuildContext context, WeekleeTableColumn column, int index)? headerBuilder;

  /// Custom builder for data cells.
  /// If provided, overrides default cell rendering.
  final Widget Function(BuildContext context, Widget cell, WeekleeTableColumn column, WeekleeTableRow row, int rowIndex, int columnIndex)? cellBuilder;

  /// Custom builder for entire rows.
  /// Useful for adding custom interactions or styling.
  final Widget Function(BuildContext context, WeekleeTableRow row, int index, Widget defaultRow)? rowBuilder;

  /// Builder for empty state when no rows are provided.
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Builder for loading state.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Optional footer rows (e.g., totals, summaries).
  final List<WeekleeTableRow>? footerRows;

  /// Whether to show checkboxes for row selection.
  final bool showCheckboxes;

  /// Custom builder for checkboxes.
  final Widget Function(BuildContext context, bool? value, ValueChanged<bool?>? onChanged)? checkboxBuilder;

  /// Callback when the header checkbox is toggled (select all).
  final ValueChanged<bool?>? onSelectAll;

  /// Set of selected row indices.
  final Set<int> selectedRows;

  /// Callback when a row's selection state changes.
  final ValueChanged<int>? onRowSelected;

  /// Builder for expandable row content.
  /// Return null if the row is not expandable.
  final Widget? Function(BuildContext context, WeekleeTableRow row, int index)? expandableRowBuilder;

  /// Set of expanded row indices.
  final Set<int> expandedRows;

  /// Callback when a row's expansion state changes.
  final ValueChanged<int>? onRowExpanded;

  /// Whether the table is in loading state.
  final bool isLoading;

  /// Callback when a column header is tapped for sorting.
  final void Function(int columnIndex)? onSort;

  /// Index of the currently sorted column.
  final int? sortColumnIndex;

  /// Whether the sort is ascending.
  final bool sortAscending;

  /// Optional row groups for organizing data.
  final List<WeekleeTableGroup>? groups;

  /// Builder for group headers.
  final Widget Function(BuildContext context, WeekleeTableGroup group, int index)? groupHeaderBuilder;

  /// Callback when a row is tapped.
  final ValueChanged<int>? onRowTap;

  /// Callback when a row is double-tapped.
  final ValueChanged<int>? onRowDoubleTap;

  /// Callback when a row is long-pressed.
  final ValueChanged<int>? onRowLongPress;

  /// Callback when a cell is tapped.
  final void Function(int rowIndex, int columnIndex)? onCellTap;

  /// Border style for the table.
  final TableBorder? border;

  /// Custom divider between rows.
  final Widget? divider;

  @override
  State<WeekleeTable> createState() => _WeekleeTableState();
}

class _WeekleeTableState extends State<WeekleeTable> {
  late Set<int> _selectedRows;
  late Set<int> _expandedRows;
  final Map<int, bool> _hoveredRows = {};

  @override
  void initState() {
    super.initState();
    _selectedRows = Set.from(widget.selectedRows);
    _expandedRows = Set.from(widget.expandedRows);
  }

  @override
  void didUpdateWidget(WeekleeTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRows != oldWidget.selectedRows) {
      _selectedRows = Set.from(widget.selectedRows);
    }
    if (widget.expandedRows != oldWidget.expandedRows) {
      _expandedRows = Set.from(widget.expandedRows);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? WeekleeTableTheme.defaultTheme(context);

    // Show loading state
    if (widget.isLoading) {
      return widget.loadingBuilder?.call(context) ?? _buildDefaultLoading(theme);
    }

    // Show empty state
    if (widget.rows.isEmpty && widget.groups == null) {
      return widget.emptyBuilder?.call(context) ?? _buildDefaultEmpty(theme);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTable(context, theme),
      ],
    );
  }

  Widget _buildTable(BuildContext context, WeekleeTableTheme theme) {
    return Table(
      border: widget.border ?? theme.border,
      columnWidths: _buildColumnWidths(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Header row
        _buildHeaderRow(context, theme),
        // Data rows (with groups if provided)
        if (widget.groups != null)
          ..._buildGroupedRows(context, theme)
        else
          ..._buildDataRows(context, theme),
        // Footer rows
        if (widget.footerRows != null) ..._buildFooterRows(context, theme),
      ],
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths() {
    final widths = <int, TableColumnWidth>{};
    int offset = 0;

    // Checkbox column
    if (widget.showCheckboxes) {
      widths[0] = const FixedColumnWidth(48);
      offset = 1;
    }

    // Data columns
    for (var i = 0; i < widget.columns.length; i++) {
      final column = widget.columns[i];
      widths[i + offset] = column.width ?? const FlexColumnWidth(1);
    }

    // Expansion indicator column
    if (widget.expandableRowBuilder != null) {
      widths[widget.columns.length + offset] = const FixedColumnWidth(48);
    }

    return widths;
  }

  TableRow _buildHeaderRow(BuildContext context, WeekleeTableTheme theme) {
    final cells = <Widget>[];

    // Checkbox column header
    if (widget.showCheckboxes) {
      final allSelected = widget.rows.isNotEmpty &&
          _selectedRows.length == widget.rows.length;
      final someSelected = _selectedRows.isNotEmpty &&
          _selectedRows.length < widget.rows.length;

      cells.add(
        Container(
          padding: theme.headerCellPadding,
          alignment: Alignment.center,
          child: widget.checkboxBuilder?.call(
            context,
            allSelected ? true : (someSelected ? null : false),
            (value) {
              setState(() {
                if (value == true) {
                  _selectedRows = Set.from(List.generate(widget.rows.length, (i) => i));
                } else {
                  _selectedRows.clear();
                }
              });
              widget.onSelectAll?.call(value);
            },
          ) ?? Checkbox(
            value: allSelected ? true : (someSelected ? null : false),
            tristate: true,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedRows = Set.from(List.generate(widget.rows.length, (i) => i));
                } else {
                  _selectedRows.clear();
                }
              });
              widget.onSelectAll?.call(value);
            },
          ),
        ),
      );
    }

    // Data column headers
    for (var i = 0; i < widget.columns.length; i++) {
      final column = widget.columns[i];
      cells.add(_buildHeaderCell(context, column, i, theme));
    }

    // Expansion indicator column header
    if (widget.expandableRowBuilder != null) {
      cells.add(const SizedBox(width: 48));
    }

    return TableRow(
      decoration: theme.headerDecoration,
      children: cells,
    );
  }

  Widget _buildHeaderCell(BuildContext context, WeekleeTableColumn column, int index, WeekleeTableTheme theme) {
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(context, column, index);
    }

    Widget headerContent = column.header;

    // Add sort indicator if column is sortable
    if (column.sortable && widget.sortColumnIndex == index) {
      headerContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: headerContent),
          const SizedBox(width: 4),
          Icon(
            widget.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: theme.sortIconColor,
          ),
        ],
      );
    }

    return InkWell(
      onTap: column.sortable && widget.onSort != null
          ? () => widget.onSort!(index)
          : column.onTap,
      child: Container(
        padding: column.headerPadding ?? theme.headerCellPadding,
        alignment: column.headerAlignment ?? theme.headerCellAlignment,
        child: DefaultTextStyle(
          style: theme.headerTextStyle ?? const TextStyle(fontWeight: FontWeight.bold),
          child: headerContent,
        ),
      ),
    );
  }

  List<TableRow> _buildGroupedRows(BuildContext context, WeekleeTableTheme theme) {
    final rows = <TableRow>[];
    final groups = widget.groups!;

    for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) {
      final group = groups[groupIndex];

      // Add group header
      rows.add(_buildGroupHeader(context, group, groupIndex, theme));

      // Add rows in this group
      for (var rowIndex = group.startIndex; rowIndex <= group.endIndex && rowIndex < widget.rows.length; rowIndex++) {
        final row = widget.rows[rowIndex];
        rows.add(_buildDataRow(context, row, rowIndex, theme));

        // Add expandable content if expanded
        if (_expandedRows.contains(rowIndex) && widget.expandableRowBuilder != null) {
          rows.add(_buildExpandedRow(context, row, rowIndex, theme));
        }

        // Add divider
        if (widget.divider != null && rowIndex < group.endIndex) {
          rows.add(_buildDividerRow());
        }
      }
    }

    return rows;
  }

  TableRow _buildGroupHeader(BuildContext context, WeekleeTableGroup group, int index, WeekleeTableTheme theme) {
    final cellCount = widget.columns.length +
        (widget.showCheckboxes ? 1 : 0) +
        (widget.expandableRowBuilder != null ? 1 : 0);

    Widget content;
    if (widget.groupHeaderBuilder != null) {
      content = widget.groupHeaderBuilder!(context, group, index);
    } else {
      content = Container(
        padding: theme.groupHeaderPadding ?? theme.cellPadding,
        alignment: Alignment.centerLeft,
        child: DefaultTextStyle(
          style: theme.groupHeaderTextStyle ?? const TextStyle(fontWeight: FontWeight.bold),
          child: group.header,
        ),
      );
    }

    return TableRow(
      decoration: theme.groupHeaderDecoration ?? theme.headerDecoration,
      children: [
        content,
        ...List.generate(cellCount - 1, (_) => const SizedBox.shrink()),
      ],
    );
  }

  List<TableRow> _buildDataRows(BuildContext context, WeekleeTableTheme theme) {
    final rows = <TableRow>[];

    for (var i = 0; i < widget.rows.length; i++) {
      final row = widget.rows[i];
      rows.add(_buildDataRow(context, row, i, theme));

      // Add expandable content if expanded
      if (_expandedRows.contains(i) && widget.expandableRowBuilder != null) {
        rows.add(_buildExpandedRow(context, row, i, theme));
      }

      // Add divider
      if (widget.divider != null && i < widget.rows.length - 1) {
        rows.add(_buildDividerRow());
      }
    }

    return rows;
  }

  TableRow _buildDataRow(BuildContext context, WeekleeTableRow row, int index, WeekleeTableTheme theme) {
    final cells = <Widget>[];
    final isHovered = _hoveredRows[index] ?? false;
    final isSelected = _selectedRows.contains(index);

    // Checkbox column
    if (widget.showCheckboxes) {
      cells.add(
        Container(
          padding: theme.cellPadding,
          alignment: Alignment.center,
          child: widget.checkboxBuilder?.call(
            context,
            isSelected,
            (value) {
              setState(() {
                if (value == true) {
                  _selectedRows.add(index);
                } else {
                  _selectedRows.remove(index);
                }
              });
              widget.onRowSelected?.call(index);
            },
          ) ?? Checkbox(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedRows.add(index);
                } else {
                  _selectedRows.remove(index);
                }
              });
              widget.onRowSelected?.call(index);
            },
          ),
        ),
      );
    }

    // Data cells
    for (var i = 0; i < widget.columns.length; i++) {
      if (i >= row.cells.length) {
        cells.add(const SizedBox.shrink());
        continue;
      }

      final column = widget.columns[i];
      final cell = row.cells[i];
      cells.add(_buildDataCell(context, cell, column, row, index, i, theme));
    }

    // Expansion indicator
    if (widget.expandableRowBuilder != null) {
      final isExpandable = widget.expandableRowBuilder!(context, row, index) != null;
      cells.add(
        Container(
          padding: theme.cellPadding,
          alignment: Alignment.center,
          child: isExpandable
              ? InkWell(
                  onTap: () {
                    setState(() {
                      if (_expandedRows.contains(index)) {
                        _expandedRows.remove(index);
                      } else {
                        _expandedRows.add(index);
                      }
                    });
                    widget.onRowExpanded?.call(index);
                  },
                  child: Icon(
                    _expandedRows.contains(index)
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 20,
                  ),
                )
              : null,
        ),
      );
    }

    // Build row with hover effect and interactions
    final decoration = row.decoration ??
        (isSelected
            ? theme.selectedRowDecoration
            : (isHovered ? theme.hoveredRowDecoration : theme.rowDecoration));

    if (theme.enableHoverEffect) {
      return TableRow(
        decoration: decoration,
        children: cells.map((cell) {
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRows[index] = true),
            onExit: (_) => setState(() => _hoveredRows[index] = false),
            child: GestureDetector(
              onTap: () {
                widget.onRowTap?.call(index);
                row.onTap?.call();
              },
              onDoubleTap: () => widget.onRowDoubleTap?.call(index),
              onLongPress: () => widget.onRowLongPress?.call(index),
              child: cell,
            ),
          );
        }).toList(),
      );
    }

    return TableRow(
      decoration: decoration,
      children: cells,
    );
  }

  Widget _buildDataCell(BuildContext context, Widget cell, WeekleeTableColumn column, WeekleeTableRow row, int rowIndex, int columnIndex, WeekleeTableTheme theme) {
    if (widget.cellBuilder != null) {
      return widget.cellBuilder!(context, cell, column, row, rowIndex, columnIndex);
    }

    return InkWell(
      onTap: widget.onCellTap != null
          ? () => widget.onCellTap!(rowIndex, columnIndex)
          : null,
      child: Container(
        padding: column.cellPadding ?? row.cellPadding ?? theme.cellPadding,
        alignment: column.cellAlignment ?? row.cellAlignment ?? theme.cellAlignment,
        constraints: column.constraints,
        child: cell,
      ),
    );
  }

  TableRow _buildExpandedRow(BuildContext context, WeekleeTableRow row, int index, WeekleeTableTheme theme) {
    final cellCount = widget.columns.length +
        (widget.showCheckboxes ? 1 : 0) +
        (widget.expandableRowBuilder != null ? 1 : 0);

    final expandedContent = widget.expandableRowBuilder!(context, row, index);
    if (expandedContent == null) {
      return TableRow(children: List.generate(cellCount, (_) => const SizedBox.shrink()));
    }

    return TableRow(
      decoration: theme.expandedRowDecoration,
      children: [
        Container(
          padding: theme.expandedRowPadding ?? theme.cellPadding,
          child: expandedContent,
        ),
        ...List.generate(cellCount - 1, (_) => const SizedBox.shrink()),
      ],
    );
  }

  TableRow _buildDividerRow() {
    final cellCount = widget.columns.length +
        (widget.showCheckboxes ? 1 : 0) +
        (widget.expandableRowBuilder != null ? 1 : 0);

    return TableRow(
      children: [
        widget.divider!,
        ...List.generate(cellCount - 1, (_) => const SizedBox.shrink()),
      ],
    );
  }

  List<TableRow> _buildFooterRows(BuildContext context, WeekleeTableTheme theme) {
    return widget.footerRows!.map((row) {
      final cells = <Widget>[];

      // Checkbox column spacer
      if (widget.showCheckboxes) {
        cells.add(const SizedBox.shrink());
      }

      // Footer cells
      for (var i = 0; i < widget.columns.length; i++) {
        if (i >= row.cells.length) {
          cells.add(const SizedBox.shrink());
          continue;
        }

        final column = widget.columns[i];
        final cell = row.cells[i];
        cells.add(
          Container(
            padding: column.cellPadding ?? row.cellPadding ?? theme.footerCellPadding ?? theme.cellPadding,
            alignment: column.cellAlignment ?? row.cellAlignment ?? theme.footerCellAlignment ?? theme.cellAlignment,
            child: DefaultTextStyle(
              style: theme.footerTextStyle ?? const TextStyle(fontWeight: FontWeight.bold),
              child: cell,
            ),
          ),
        );
      }

      // Expansion column spacer
      if (widget.expandableRowBuilder != null) {
        cells.add(const SizedBox.shrink());
      }

      return TableRow(
        decoration: row.decoration ?? theme.footerDecoration,
        children: cells,
      );
    }).toList();
  }

  Widget _buildDefaultLoading(WeekleeTableTheme theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildDefaultEmpty(WeekleeTableTheme theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Text(
        'No data available',
        style: theme.emptyTextStyle ?? TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}

/// Defines a column in the table.
class WeekleeTableColumn {
  const WeekleeTableColumn({
    required this.header,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.sortable = false,
    this.onTap,
    this.headerPadding,
    this.headerAlignment,
    this.cellPadding,
    this.cellAlignment,
    this.constraints,
  });

  /// Widget to display in the header.
  final Widget header;

  /// Column width strategy.
  /// Can be FlexColumnWidth, FixedColumnWidth, IntrinsicColumnWidth, or FractionColumnWidth.
  final TableColumnWidth? width;

  /// Minimum width constraint (optional).
  final double? minWidth;

  /// Maximum width constraint (optional).
  final double? maxWidth;

  /// Whether this column is sortable.
  final bool sortable;

  /// Callback when header is tapped (if not sortable).
  final VoidCallback? onTap;

  /// Padding for the header cell.
  final EdgeInsets? headerPadding;

  /// Alignment for the header cell.
  final Alignment? headerAlignment;

  /// Padding for data cells in this column.
  final EdgeInsets? cellPadding;

  /// Alignment for data cells in this column.
  final Alignment? cellAlignment;

  /// Box constraints for cells in this column.
  final BoxConstraints? constraints;
}

/// Defines a row in the table.
class WeekleeTableRow {
  const WeekleeTableRow({
    required this.cells,
    this.decoration,
    this.onTap,
    this.cellPadding,
    this.cellAlignment,
    this.key,
  });

  /// List of widgets for each cell.
  final List<Widget> cells;

  /// Optional decoration for the row.
  final BoxDecoration? decoration;

  /// Callback when the row is tapped.
  final VoidCallback? onTap;

  /// Padding for all cells in this row.
  final EdgeInsets? cellPadding;

  /// Alignment for all cells in this row.
  final Alignment? cellAlignment;

  /// Optional key for the row (useful for animations).
  final Key? key;
}

/// Defines a group of rows.
class WeekleeTableGroup {
  const WeekleeTableGroup({
    required this.header,
    required this.startIndex,
    required this.endIndex,
    this.key,
  });

  /// Widget to display in the group header.
  final Widget header;

  /// Starting row index (inclusive).
  final int startIndex;

  /// Ending row index (inclusive).
  final int endIndex;

  /// Optional key for the group.
  final Key? key;
}

/// Theme configuration for WeekleeTable.
class WeekleeTableTheme {
  const WeekleeTableTheme({
    this.headerDecoration,
    this.rowDecoration,
    this.alternateRowDecoration,
    this.hoveredRowDecoration,
    this.selectedRowDecoration,
    this.footerDecoration,
    this.expandedRowDecoration,
    this.groupHeaderDecoration,
    this.border,
    this.headerCellPadding = const EdgeInsets.all(12),
    this.cellPadding = const EdgeInsets.all(12),
    this.footerCellPadding,
    this.expandedRowPadding,
    this.groupHeaderPadding,
    this.headerCellAlignment = Alignment.centerLeft,
    this.cellAlignment = Alignment.centerLeft,
    this.footerCellAlignment,
    this.headerTextStyle,
    this.cellTextStyle,
    this.footerTextStyle,
    this.groupHeaderTextStyle,
    this.emptyTextStyle,
    this.sortIconColor,
    this.enableHoverEffect = true,
  });

  final BoxDecoration? headerDecoration;
  final BoxDecoration? rowDecoration;
  final BoxDecoration? alternateRowDecoration;
  final BoxDecoration? hoveredRowDecoration;
  final BoxDecoration? selectedRowDecoration;
  final BoxDecoration? footerDecoration;
  final BoxDecoration? expandedRowDecoration;
  final BoxDecoration? groupHeaderDecoration;
  final TableBorder? border;
  final EdgeInsets headerCellPadding;
  final EdgeInsets cellPadding;
  final EdgeInsets? footerCellPadding;
  final EdgeInsets? expandedRowPadding;
  final EdgeInsets? groupHeaderPadding;
  final Alignment headerCellAlignment;
  final Alignment cellAlignment;
  final Alignment? footerCellAlignment;
  final TextStyle? headerTextStyle;
  final TextStyle? cellTextStyle;
  final TextStyle? footerTextStyle;
  final TextStyle? groupHeaderTextStyle;
  final TextStyle? emptyTextStyle;
  final Color? sortIconColor;
  final bool enableHoverEffect;

  /// Creates a default theme based on the app's theme.
  factory WeekleeTableTheme.defaultTheme(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return WeekleeTableTheme(
      headerDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline),
        ),
      ),
      rowDecoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      alternateRowDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
      ),
      hoveredRowDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
      ),
      selectedRowDecoration: BoxDecoration(
        color: colorScheme.primaryContainer,
      ),
      footerDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: colorScheme.outline),
        ),
      ),
      expandedRowDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
      ),
      groupHeaderDecoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
      ),
      border: TableBorder(
        horizontalInside: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      headerTextStyle: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      cellTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      footerTextStyle: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      groupHeaderTextStyle: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSecondaryContainer,
      ),
      emptyTextStyle: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      sortIconColor: colorScheme.primary,
    );
  }

  /// Creates a minimal theme with no decorations.
  factory WeekleeTableTheme.minimal() {
    return const WeekleeTableTheme(
      enableHoverEffect: false,
    );
  }

  /// Creates a theme with alternating row colors.
  factory WeekleeTableTheme.striped(BuildContext context) {
    final defaultTheme = WeekleeTableTheme.defaultTheme(context);
    return defaultTheme;
  }

  WeekleeTableTheme copyWith({
    BoxDecoration? headerDecoration,
    BoxDecoration? rowDecoration,
    BoxDecoration? alternateRowDecoration,
    BoxDecoration? hoveredRowDecoration,
    BoxDecoration? selectedRowDecoration,
    BoxDecoration? footerDecoration,
    BoxDecoration? expandedRowDecoration,
    BoxDecoration? groupHeaderDecoration,
    TableBorder? border,
    EdgeInsets? headerCellPadding,
    EdgeInsets? cellPadding,
    EdgeInsets? footerCellPadding,
    EdgeInsets? expandedRowPadding,
    EdgeInsets? groupHeaderPadding,
    Alignment? headerCellAlignment,
    Alignment? cellAlignment,
    Alignment? footerCellAlignment,
    TextStyle? headerTextStyle,
    TextStyle? cellTextStyle,
    TextStyle? footerTextStyle,
    TextStyle? groupHeaderTextStyle,
    TextStyle? emptyTextStyle,
    Color? sortIconColor,
    bool? enableHoverEffect,
  }) {
    return WeekleeTableTheme(
      headerDecoration: headerDecoration ?? this.headerDecoration,
      rowDecoration: rowDecoration ?? this.rowDecoration,
      alternateRowDecoration: alternateRowDecoration ?? this.alternateRowDecoration,
      hoveredRowDecoration: hoveredRowDecoration ?? this.hoveredRowDecoration,
      selectedRowDecoration: selectedRowDecoration ?? this.selectedRowDecoration,
      footerDecoration: footerDecoration ?? this.footerDecoration,
      expandedRowDecoration: expandedRowDecoration ?? this.expandedRowDecoration,
      groupHeaderDecoration: groupHeaderDecoration ?? this.groupHeaderDecoration,
      border: border ?? this.border,
      headerCellPadding: headerCellPadding ?? this.headerCellPadding,
      cellPadding: cellPadding ?? this.cellPadding,
      footerCellPadding: footerCellPadding ?? this.footerCellPadding,
      expandedRowPadding: expandedRowPadding ?? this.expandedRowPadding,
      groupHeaderPadding: groupHeaderPadding ?? this.groupHeaderPadding,
      headerCellAlignment: headerCellAlignment ?? this.headerCellAlignment,
      cellAlignment: cellAlignment ?? this.cellAlignment,
      footerCellAlignment: footerCellAlignment ?? this.footerCellAlignment,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      cellTextStyle: cellTextStyle ?? this.cellTextStyle,
      footerTextStyle: footerTextStyle ?? this.footerTextStyle,
      groupHeaderTextStyle: groupHeaderTextStyle ?? this.groupHeaderTextStyle,
      emptyTextStyle: emptyTextStyle ?? this.emptyTextStyle,
      sortIconColor: sortIconColor ?? this.sortIconColor,
      enableHoverEffect: enableHoverEffect ?? this.enableHoverEffect,
    );
  }
}
