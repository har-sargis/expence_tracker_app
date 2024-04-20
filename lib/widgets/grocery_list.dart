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
  late Future<List<GroceryItem>> _loadedItems;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https('expense-tracker-769fc-default-rtdb.firebaseio.com',
        'grocery_list.json');

    final res = await http.get(url);
    if (res.body == 'null') {
      return [];
    }

    if (res.statusCode >= 400) {
      throw 'Failed to load groceries';
    }

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

    return loadedItems;
  }

  void _removeItem(String id) async {
    final grocery = _groceries.firstWhere((element) => element.id == id);
    final url = Uri.https('expense-tracker-769fc-default-rtdb.firebaseio.com',
        'grocery_list/$id.json');
    setState(() {
      _groceries.removeWhere((element) => element.id == id);
    });

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceries.add(grocery);
      });
    }
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
      body: FutureBuilder(
        future: _loadedItems,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load groceries'),
                  ElevatedButton(
                    onPressed: _loadItems,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            _groceries = snapshot.data as List<GroceryItem>;
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: const Text('No groceries found'),
            );
          }
          _groceries = snapshot.data as List<GroceryItem>;
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final grocery = snapshot.data![index];
              return Dismissible(
                key: ValueKey(grocery.id),
                onDismissed: (direction) {
                  _removeItem(grocery.id);
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
        }),
      ),
    );
  }
}
