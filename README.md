# WeekleeTable

A highly customizable, dynamic, and feature-rich table widget for Flutter. Built to be flexible, easy to use, and completely free of built-in scrolling (wrap it in your preferred scroll solution).

## Features

- **Flexible Column Widths**: Use `FlexColumnWidth`, `FixedColumnWidth`, `IntrinsicColumnWidth`, or `FractionColumnWidth`
- **Sortable Columns**: Built-in sort indicators and callbacks
- **Expandable Rows**: Show/hide additional content per row
- **Row Selection**: Checkbox support with custom builders
- **Row Grouping**: Organize data into collapsible sections
- **Hover Effects**: Interactive row hover states
- **Footer Rows**: Perfect for totals and summaries
- **Empty & Loading States**: Customizable placeholders
- **Comprehensive Theming**: Pre-built themes and full customization
- **Cell-Level Control**: Custom builders for headers, cells, and rows
- **Multiple Interactions**: Tap, double-tap, long-press callbacks
- **No Built-in Scrolling**: Integrate with your own scroll solution

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  weeklee_table:
    path: packages/weeklee_table
```

Then run:
```bash
flutter pub get
```

## Basic Usage

```dart
import 'package:weeklee_table/weeklee_table.dart';

WeekleeTable(
  columns: [
    WeekleeTableColumn(
      header: Text('Name'),
      width: FlexColumnWidth(2),
    ),
    WeekleeTableColumn(
      header: Text('Age'),
      width: FixedColumnWidth(100),
    ),
    WeekleeTableColumn(
      header: Text('City'),
      width: FlexColumnWidth(1),
    ),
  ],
  rows: [
    WeekleeTableRow(
      cells: [
        Text('Alice Johnson'),
        Text('28'),
        Text('New York'),
      ],
    ),
    WeekleeTableRow(
      cells: [
        Text('Bob Smith'),
        Text('34'),
        Text('Los Angeles'),
      ],
    ),
  ],
)
```

## Advanced Examples

### 1. Sortable Table with Theme

```dart
class SortableTableExample extends StatefulWidget {
  @override
  State<SortableTableExample> createState() => _SortableTableExampleState();
}

class _SortableTableExampleState extends State<SortableTableExample> {
  int? sortColumnIndex;
  bool sortAscending = true;
  List<Person> people = [...]; // Your data

  void _sort(int columnIndex) {
    setState(() {
      if (sortColumnIndex == columnIndex) {
        sortAscending = !sortAscending;
      } else {
        sortColumnIndex = columnIndex;
        sortAscending = true;
      }

      // Sort your data based on columnIndex and sortAscending
      people.sort((a, b) {
        switch (columnIndex) {
          case 0: return sortAscending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name);
          case 1: return sortAscending
              ? a.age.compareTo(b.age)
              : b.age.compareTo(a.age);
          default: return 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WeekleeTable(
      theme: WeekleeTableTheme.defaultTheme(context),
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      onSort: _sort,
      columns: [
        WeekleeTableColumn(
          header: Text('Name'),
          sortable: true,
          width: FlexColumnWidth(2),
        ),
        WeekleeTableColumn(
          header: Text('Age'),
          sortable: true,
          width: FixedColumnWidth(100),
        ),
        WeekleeTableColumn(
          header: Text('City'),
          width: FlexColumnWidth(1),
        ),
      ],
      rows: people.map((person) => WeekleeTableRow(
        cells: [
          Text(person.name),
          Text('${person.age}'),
          Text(person.city),
        ],
      )).toList(),
    );
  }
}
```

### 2. Table with Row Selection

```dart
class SelectableTableExample extends StatefulWidget {
  @override
  State<SelectableTableExample> createState() => _SelectableTableExampleState();
}

class _SelectableTableExampleState extends State<SelectableTableExample> {
  Set<int> selectedRows = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Selected: ${selectedRows.length} rows'),
        WeekleeTable(
          showCheckboxes: true,
          selectedRows: selectedRows,
          onRowSelected: (index) {
            setState(() {
              if (selectedRows.contains(index)) {
                selectedRows.remove(index);
              } else {
                selectedRows.add(index);
              }
            });
          },
          onSelectAll: (selected) {
            setState(() {
              if (selected == true) {
                selectedRows = Set.from(List.generate(10, (i) => i));
              } else {
                selectedRows.clear();
              }
            });
          },
          columns: [
            WeekleeTableColumn(header: Text('Name')),
            WeekleeTableColumn(header: Text('Status')),
          ],
          rows: List.generate(10, (i) => WeekleeTableRow(
            cells: [
              Text('Item $i'),
              Text('Active'),
            ],
          )),
        ),
      ],
    );
  }
}
```

### 3. Expandable Rows

```dart
WeekleeTable(
  expandableRowBuilder: (context, row, index) {
    // Return null for non-expandable rows
    if (index == 2) return null;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Additional details for row $index'),
          SizedBox(height: 8),
          Text('This content is shown when the row is expanded'),
        ],
      ),
    );
  },
  columns: [
    WeekleeTableColumn(header: Text('Product')),
    WeekleeTableColumn(header: Text('Price')),
  ],
  rows: [
    WeekleeTableRow(cells: [Text('Product A'), Text('\$29.99')]),
    WeekleeTableRow(cells: [Text('Product B'), Text('\$49.99')]),
    WeekleeTableRow(cells: [Text('Product C'), Text('\$19.99')]),
  ],
)
```

### 4. Grouped Rows

```dart
WeekleeTable(
  groups: [
    WeekleeTableGroup(
      header: Text('Department A'),
      startIndex: 0,
      endIndex: 2,
    ),
    WeekleeTableGroup(
      header: Text('Department B'),
      startIndex: 3,
      endIndex: 5,
    ),
  ],
  columns: [
    WeekleeTableColumn(header: Text('Employee')),
    WeekleeTableColumn(header: Text('Role')),
  ],
  rows: [
    WeekleeTableRow(cells: [Text('Alice'), Text('Manager')]),
    WeekleeTableRow(cells: [Text('Bob'), Text('Developer')]),
    WeekleeTableRow(cells: [Text('Carol'), Text('Designer')]),
    WeekleeTableRow(cells: [Text('David'), Text('Lead')]),
    WeekleeTableRow(cells: [Text('Eve'), Text('Developer')]),
    WeekleeTableRow(cells: [Text('Frank'), Text('QA')]),
  ],
)
```

### 5. Table with Footer

```dart
WeekleeTable(
  columns: [
    WeekleeTableColumn(header: Text('Item'), width: FlexColumnWidth(2)),
    WeekleeTableColumn(header: Text('Quantity'), width: FixedColumnWidth(100)),
    WeekleeTableColumn(header: Text('Price'), width: FixedColumnWidth(100)),
  ],
  rows: [
    WeekleeTableRow(cells: [Text('Apple'), Text('5'), Text('\$10.00')]),
    WeekleeTableRow(cells: [Text('Banana'), Text('3'), Text('\$6.00')]),
    WeekleeTableRow(cells: [Text('Orange'), Text('2'), Text('\$8.00')]),
  ],
  footerRows: [
    WeekleeTableRow(
      cells: [
        Text('Total'),
        Text('10'),
        Text('\$24.00'),
      ],
    ),
  ],
)
```

### 6. Custom Cell Builders

```dart
WeekleeTable(
  cellBuilder: (context, cell, column, row, rowIndex, columnIndex) {
    // Customize specific cells
    if (columnIndex == 2) {
      return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: cell,
      );
    }
    return Container(
      padding: EdgeInsets.all(12),
      child: cell,
    );
  },
  columns: [
    WeekleeTableColumn(header: Text('Name')),
    WeekleeTableColumn(header: Text('Status')),
    WeekleeTableColumn(header: Text('Action')),
  ],
  rows: [
    WeekleeTableRow(cells: [
      Text('Item 1'),
      Text('Active'),
      Icon(Icons.check_circle, color: Colors.green),
    ]),
  ],
)
```

### 7. Loading and Empty States

```dart
class LoadingTableExample extends StatefulWidget {
  @override
  State<LoadingTableExample> createState() => _LoadingTableExampleState();
}

class _LoadingTableExampleState extends State<LoadingTableExample> {
  bool isLoading = true;
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
      data = []; // Empty for demo
    });
  }

  @override
  Widget build(BuildContext context) {
    return WeekleeTable(
      isLoading: isLoading,
      loadingBuilder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading data...'),
          ],
        ),
      ),
      emptyBuilder: (context) => Container(
        padding: EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No data available', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      columns: [
        WeekleeTableColumn(header: Text('Column 1')),
        WeekleeTableColumn(header: Text('Column 2')),
      ],
      rows: data.map((item) => WeekleeTableRow(
        cells: [Text(item.toString())],
      )).toList(),
    );
  }
}
```

### 8. Custom Theme

```dart
WeekleeTable(
  theme: WeekleeTableTheme(
    headerDecoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade700, Colors.blue.shade500],
      ),
    ),
    headerTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    hoveredRowDecoration: BoxDecoration(
      color: Colors.blue.shade50,
    ),
    selectedRowDecoration: BoxDecoration(
      color: Colors.blue.shade100,
    ),
    cellPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    enableHoverEffect: true,
    border: TableBorder.all(
      color: Colors.grey.shade300,
      width: 1,
    ),
  ),
  columns: [...],
  rows: [...],
)
```

### 9. Interactive Table with Callbacks

```dart
WeekleeTable(
  onRowTap: (index) {
    print('Row $index tapped');
  },
  onRowDoubleTap: (index) {
    print('Row $index double-tapped');
  },
  onRowLongPress: (index) {
    print('Row $index long-pressed');
  },
  onCellTap: (rowIndex, columnIndex) {
    print('Cell [$rowIndex, $columnIndex] tapped');
  },
  columns: [
    WeekleeTableColumn(
      header: Text('Name'),
      onTap: () => print('Header tapped'),
    ),
    WeekleeTableColumn(header: Text('Value')),
  ],
  rows: [
    WeekleeTableRow(
      cells: [Text('Item 1'), Text('Value 1')],
      onTap: () => print('Row-specific action'),
    ),
  ],
)
```

### 10. Different Column Widths

```dart
WeekleeTable(
  columns: [
    WeekleeTableColumn(
      header: Text('ID'),
      width: FixedColumnWidth(60), // Fixed width
    ),
    WeekleeTableColumn(
      header: Text('Name'),
      width: FlexColumnWidth(3), // 3x flex
    ),
    WeekleeTableColumn(
      header: Text('Description'),
      width: FlexColumnWidth(2), // 2x flex
    ),
    WeekleeTableColumn(
      header: Text('Status'),
      width: IntrinsicColumnWidth(), // Fits content
    ),
    WeekleeTableColumn(
      header: Text('Progress'),
      width: FractionColumnWidth(0.15), // 15% of table width
    ),
  ],
  rows: [...],
)
```

## Scrolling Integration

WeekleeTable does not include built-in scrolling. Wrap it in your preferred scroll solution:

### SingleChildScrollView (Simple)

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: SingleChildScrollView(
    child: WeekleeTable(
      columns: [...],
      rows: [...],
    ),
  ),
)
```

### ListView (For Many Rows)

If you have many rows, consider using a virtualized solution. Since WeekleeTable builds all rows at once, for very large datasets you might want to implement pagination or use a different approach.

```dart
ListView(
  children: [
    WeekleeTable(
      columns: [...],
      rows: currentPageRows, // Only current page
    ),
  ],
)
```

### InteractiveViewer (With Zoom)

```dart
InteractiveViewer(
  constrained: false,
  child: WeekleeTable(
    columns: [...],
    rows: [...],
  ),
)
```

## API Reference

### WeekleeTable

| Property | Type | Description |
|----------|------|-------------|
| `columns` | `List<WeekleeTableColumn>` | Column definitions |
| `rows` | `List<WeekleeTableRow>` | Data rows |
| `theme` | `WeekleeTableTheme?` | Theme configuration |
| `showCheckboxes` | `bool` | Show selection checkboxes |
| `selectedRows` | `Set<int>` | Selected row indices |
| `expandableRowBuilder` | `Function?` | Builder for expandable content |
| `expandedRows` | `Set<int>` | Expanded row indices |
| `isLoading` | `bool` | Show loading state |
| `sortColumnIndex` | `int?` | Currently sorted column |
| `sortAscending` | `bool` | Sort direction |
| `groups` | `List<WeekleeTableGroup>?` | Row groups |
| `footerRows` | `List<WeekleeTableRow>?` | Footer rows |
| `border` | `TableBorder?` | Table border style |
| `onSort` | `Function(int)?` | Sort callback |
| `onRowTap` | `Function(int)?` | Row tap callback |
| `onRowSelected` | `Function(int)?` | Row selection callback |
| `onSelectAll` | `Function(bool?)?` | Select all callback |

### WeekleeTableColumn

| Property | Type | Description |
|----------|------|-------------|
| `header` | `Widget` | Header widget |
| `width` | `TableColumnWidth?` | Column width strategy |
| `sortable` | `bool` | Enable sorting |
| `headerPadding` | `EdgeInsets?` | Header cell padding |
| `headerAlignment` | `Alignment?` | Header cell alignment |
| `cellPadding` | `EdgeInsets?` | Data cell padding |
| `cellAlignment` | `Alignment?` | Data cell alignment |
| `constraints` | `BoxConstraints?` | Cell constraints |

### WeekleeTableRow

| Property | Type | Description |
|----------|------|-------------|
| `cells` | `List<Widget>` | Cell widgets |
| `decoration` | `BoxDecoration?` | Row decoration |
| `onTap` | `VoidCallback?` | Tap callback |
| `cellPadding` | `EdgeInsets?` | Cell padding override |
| `cellAlignment` | `Alignment?` | Cell alignment override |

### WeekleeTableTheme

Use `WeekleeTableTheme.defaultTheme(context)` for Material 3 styling, or create a custom theme:

```dart
WeekleeTableTheme(
  headerDecoration: BoxDecoration(...),
  rowDecoration: BoxDecoration(...),
  hoveredRowDecoration: BoxDecoration(...),
  selectedRowDecoration: BoxDecoration(...),
  headerTextStyle: TextStyle(...),
  cellPadding: EdgeInsets.all(12),
  enableHoverEffect: true,
  // ... and many more options
)
```

## Tips and Best Practices

1. **Column Widths**: Use `FlexColumnWidth` for responsive columns and `FixedColumnWidth` for columns with fixed content like actions or IDs.

2. **Performance**: For very large datasets, implement pagination or virtualization at the app level. WeekleeTable builds all rows at once.

3. **Theming**: Use `WeekleeTableTheme.defaultTheme(context)` to automatically match your app's Material theme.

4. **Scrolling**: Always wrap the table in a scroll view for horizontal scrolling or when content exceeds the viewport.

5. **Custom Builders**: Use `cellBuilder`, `headerBuilder`, or `rowBuilder` for complete control over rendering.

6. **Interactions**: Combine `onRowTap`, `showCheckboxes`, and `expandableRowBuilder` for rich interactions.

7. **Empty States**: Always provide `emptyBuilder` and `loadingBuilder` for better UX.

## License

MIT License - Feel free to use this package in your projects.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
