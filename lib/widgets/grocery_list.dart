import 'dart:convert';

import 'package:expence_tracker_app/data/categories.dart';
import 'package:expence_tracker_app/models/grocery.dart';
import 'package:expence_tracker_app/widgets/new_item.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceries = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('expense-tracker-769fc-default-rtdb.firebaseio.com',
        'grocery_list.json');
    final res = await http.get(url);
    final Map<String, dynamic> data = json.decode(res.body);

    final List<GroceryItem> loadedItems = [];
    for (final item in data.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: int.parse(item.value['quantity']),
        category: category,
      ));
    }
    setState(() {
      _groceries = loadedItems;
    });
  }

  void _addGroceryItem() async {
    final res = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const NewItem()));
    if (res != null) {
      setState(() {
        _groceries.add(res as GroceryItem);
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
