import 'package:expence_tracker_app/models/grocery.dart';
import 'package:expence_tracker_app/widgets/new_item.dart';
import 'package:flutter/material.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceries = [];

  void _addGroceryItem() async {
    final newItem =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (context) => const NewItem(),
    ));

    if (newItem != null) {
      setState(() {
        _groceries.add(newItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(child: const Text('No Items added yet.'));

    if (_groceries.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceries.length,
        itemBuilder: (context, index) {
          final grocery = _groceries[index];
          return Dismissible(
            key: ValueKey(grocery.id),
            onDismissed: (direction) {
              setState(() {
                _groceries.removeAt(index);
              });
            },
            child: ListTile(
              title: Text(grocery.name),
              subtitle: Text('Quantity: ${grocery.quantity}'),
              leading: CircleAvatar(
                backgroundColor: grocery.category.color,
              ),
              trailing: Text(grocery.quantity.toString()),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(
            onPressed: _addGroceryItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
