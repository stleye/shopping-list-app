import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredCategory = categories[Categories.vegetables];
  var _enteredQuantity = 1;

  void _addNewItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop(GroceryItem(
        id: DateTime.now().toString(),
        name: _enteredName,
        quantity: _enteredQuantity,
        category: _enteredCategory!,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null ||
                          value.trim().length <= 1 ||
                          value.trim().length > 50
                      ? 'Must be between 2 and 50 characters'
                      : null,
                  onSaved: (newValue) {
                    _enteredName = newValue!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(label: Text('Quantity')),
                          initialValue: '1',
                          validator: (value) => value == null ||
                                  int.tryParse(value) == null ||
                                  int.tryParse(value)! <= 0
                              ? 'Must be a valid positive number'
                              : null,
                          onSaved: (newValue) {
                            _enteredQuantity = int.parse(newValue!);
                          }),
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _enteredCategory,
                        // onSaved: (newValue) { // This is not needed
                        //   _enteredCategory = newValue;
                        // },
                        items: categories.entries.map((category) {
                          return DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _enteredCategory = value!;
                          });
                        },
                      ),
                    )
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
                        child: const Text('Reset')),
                    ElevatedButton(
                        onPressed: _addNewItem, child: const Text('Add Item'))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
