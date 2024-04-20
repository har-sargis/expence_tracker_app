import 'dart:convert';

import 'package:expence_tracker_app/data/categories.dart';
import 'package:expence_tracker_app/models/categroy.dart';
import 'package:expence_tracker_app/models/grocery.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  // final void Function(String, int) addItem;

  @override
  _NewItemState createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _name = '';
  var _quantity = 1;
  var _category = categories[Categories.vegetables]!;

  void _saveItem() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    final url = Uri.https('expense-tracker-769fc-default-rtdb.firebaseio.com',
        'grocery_list.json');
    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': _name,
        'quantity': _quantity.toString(),
        'category': _category.title,
      }),
    );

    final id = json.decode(res.body)['name'];
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop(
      GroceryItem(
        id: id,
        name: _name,
        quantity: _quantity,
        category: _category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                initialValue: '',
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length == 1 ||
                      value.trim().length > 50) {
                    return 'Please enter a name between 1 and 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _quantity.toString(),
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Please enter a name between 1 and 50 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _quantity = int.tryParse(value!)!;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _category,
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      // onChanged: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text('Add Item'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
