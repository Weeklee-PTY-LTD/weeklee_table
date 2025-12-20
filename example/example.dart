import 'package:flutter/material.dart';
import 'package:weeklee_table/weeklee_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeekleeTable Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplesPage(),
    );
  }
}

class ExamplesPage extends StatelessWidget {
  const ExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WeekleeTable Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('1. Basic Table'),
          const BasicTableExample(),
          const SizedBox(height: 32),
          _buildSectionTitle('2. Sortable Table'),
          const SortableTableExample(),
          const SizedBox(height: 32),
          _buildSectionTitle('3. Table with Selection'),
          const SelectableTableExample(),
          const SizedBox(height: 32),
          _buildSectionTitle('4. Expandable Rows'),
          const ExpandableTableExample(),
          const SizedBox(height: 32),
          _buildSectionTitle('5. Table with Footer'),
          const FooterTableExample(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Example 1: Basic Table
class BasicTableExample extends StatelessWidget {
  const BasicTableExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: WeekleeTable(
          columns: [
            WeekleeTableColumn(
              header: const Text('Name'),
              width: const FlexColumnWidth(2),
            ),
            WeekleeTableColumn(
              header: const Text('Age'),
              width: const FixedColumnWidth(80),
            ),
            WeekleeTableColumn(
              header: const Text('City'),
              width: const FlexColumnWidth(1),
            ),
          ],
          rows: [
            WeekleeTableRow(
              cells: [
                const Text('Alice Johnson'),
                const Text('28'),
                const Text('New York'),
              ],
            ),
            WeekleeTableRow(
              cells: [
                const Text('Bob Smith'),
                const Text('34'),
                const Text('Los Angeles'),
              ],
            ),
            WeekleeTableRow(
              cells: [
                const Text('Carol White'),
                const Text('25'),
                const Text('Chicago'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Example 2: Sortable Table
class SortableTableExample extends StatefulWidget {
  const SortableTableExample({super.key});

  @override
  State<SortableTableExample> createState() => _SortableTableExampleState();
}

class _SortableTableExampleState extends State<SortableTableExample> {
  int? sortColumnIndex;
  bool sortAscending = true;
  List<Person> people = [
    Person('Alice Johnson', 28, 'New York'),
    Person('Bob Smith', 34, 'Los Angeles'),
    Person('Carol White', 25, 'Chicago'),
    Person('David Brown', 42, 'Houston'),
  ];

  void _sort(int columnIndex) {
    setState(() {
      if (sortColumnIndex == columnIndex) {
        sortAscending = !sortAscending;
      } else {
        sortColumnIndex = columnIndex;
        sortAscending = true;
      }

      switch (columnIndex) {
        case 0:
          people.sort((a, b) => sortAscending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name));
          break;
        case 1:
          people.sort((a, b) =>
              sortAscending ? a.age.compareTo(b.age) : b.age.compareTo(a.age));
          break;
        case 2:
          people.sort((a, b) => sortAscending
              ? a.city.compareTo(b.city)
              : b.city.compareTo(a.city));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: WeekleeTable(
          theme: WeekleeTableTheme.defaultTheme(context),
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          onSort: _sort,
          columns: [
            WeekleeTableColumn(
              header: const Text('Name'),
              sortable: true,
              width: const FlexColumnWidth(2),
            ),
            WeekleeTableColumn(
              header: const Text('Age'),
              sortable: true,
              width: const FixedColumnWidth(80),
            ),
            WeekleeTableColumn(
              header: const Text('City'),
              sortable: true,
              width: const FlexColumnWidth(1),
            ),
          ],
          rows: people
              .map((person) => WeekleeTableRow(
                    cells: [
                      Text(person.name),
                      Text('${person.age}'),
                      Text(person.city),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// Example 3: Selectable Table
class SelectableTableExample extends StatefulWidget {
  const SelectableTableExample({super.key});

  @override
  State<SelectableTableExample> createState() => _SelectableTableExampleState();
}

class _SelectableTableExampleState extends State<SelectableTableExample> {
  Set<int> selectedRows = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Selected: ${selectedRows.length} rows',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
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
                    selectedRows = Set.from(List.generate(5, (i) => i));
                  } else {
                    selectedRows.clear();
                  }
                });
              },
              columns: [
                WeekleeTableColumn(header: const Text('Item')),
                WeekleeTableColumn(header: const Text('Status')),
              ],
              rows: List.generate(
                5,
                (i) => WeekleeTableRow(
                  cells: [
                    Text('Item ${i + 1}'),
                    Text('Active'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 4: Expandable Table
class ExpandableTableExample extends StatefulWidget {
  const ExpandableTableExample({super.key});

  @override
  State<ExpandableTableExample> createState() => _ExpandableTableExampleState();
}

class _ExpandableTableExampleState extends State<ExpandableTableExample> {
  Set<int> expandedRows = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: WeekleeTable(
          expandedRows: expandedRows,
          onRowExpanded: (index) {
            setState(() {
              if (expandedRows.contains(index)) {
                expandedRows.remove(index);
              } else {
                expandedRows.add(index);
              }
            });
          },
          expandableRowBuilder: (context, row, index) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional details for row $index',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('This content is shown when the row is expanded.'),
                  const SizedBox(height: 8),
                  const Text(
                      'You can put any widget here: images, forms, lists, etc.'),
                ],
              ),
            );
          },
          columns: [
            WeekleeTableColumn(header: const Text('Product')),
            WeekleeTableColumn(header: const Text('Price')),
          ],
          rows: [
            WeekleeTableRow(
                cells: [const Text('Product A'), const Text('\$29.99')]),
            WeekleeTableRow(
                cells: [const Text('Product B'), const Text('\$49.99')]),
            WeekleeTableRow(
                cells: [const Text('Product C'), const Text('\$19.99')]),
          ],
        ),
      ),
    );
  }
}

// Example 5: Table with Footer
class FooterTableExample extends StatelessWidget {
  const FooterTableExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: WeekleeTable(
          columns: [
            WeekleeTableColumn(
              header: const Text('Item'),
              width: const FlexColumnWidth(2),
            ),
            WeekleeTableColumn(
              header: const Text('Quantity'),
              width: const FixedColumnWidth(100),
              cellAlignment: Alignment.centerRight,
            ),
            WeekleeTableColumn(
              header: const Text('Price'),
              width: const FixedColumnWidth(100),
              cellAlignment: Alignment.centerRight,
            ),
          ],
          rows: [
            WeekleeTableRow(
              cells: [
                const Text('Apple'),
                const Text('5', textAlign: TextAlign.right),
                const Text('\$10.00', textAlign: TextAlign.right),
              ],
            ),
            WeekleeTableRow(
              cells: [
                const Text('Banana'),
                const Text('3', textAlign: TextAlign.right),
                const Text('\$6.00', textAlign: TextAlign.right),
              ],
            ),
            WeekleeTableRow(
              cells: [
                const Text('Orange'),
                const Text('2', textAlign: TextAlign.right),
                const Text('\$8.00', textAlign: TextAlign.right),
              ],
            ),
          ],
          footerRows: [
            WeekleeTableRow(
              cells: [
                const Text('Total'),
                const Text('10', textAlign: TextAlign.right),
                const Text('\$24.00', textAlign: TextAlign.right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for sortable example
class Person {
  final String name;
  final int age;
  final String city;

  Person(this.name, this.age, this.city);
}
