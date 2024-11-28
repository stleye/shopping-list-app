import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shopping_list_app/data/categories.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryList = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    _isLoading = true;

    try {
      final response = await http.get(Uri.https(
        'shopping-list-app-3f378-default-rtdb.firebaseio.com',
        '/shopping-list.json',
      ));

      _isLoading = false;

      if (response.statusCode >= 400) {
        throw 'Failed to load items, please try again later.';
      }

      if (response.body == 'null') {
        return;
      }

      final List<GroceryItem> loadedItems = [];
      final Map<String, dynamic> listData = json.decode(response.body);

      for (final entry in listData.entries) {
        final category = categories.entries.firstWhere(
            (catItem) => catItem.value.name == entry.value['category']);
        loadedItems.add(GroceryItem(
          id: entry.key,
          name: entry.value['name'],
          quantity: entry.value['quantity'],
          category: category.value,
        ));
      }

      setState(() {
        _groceryList = loadedItems;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = 'Something went wrong, please try again later.';
      });
    }
  }

  void _addNewItem() async {
    final item = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) {
          return const NewItem();
        },
      ),
    );

    if (item != null) {
      setState(() {
        _groceryList.add(item);
      });
    }
  }

  void _removeItem(GroceryItem item) async {
    final response = await http.delete(Uri.https(
      'shopping-list-app-3f378-default-rtdb.firebaseio.com',
      '/shopping-list/${item.id}.json',
    ));
    if (response.statusCode >= 400) {
      return;
    }
    setState(() {
      _groceryList.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items yet!'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    if (_groceryList.isNotEmpty) {
      content = ListView(
        children: [
          ..._groceryList.map((item) {
            return Dismissible(
              onDismissed: (direction) => _removeItem(item),
              key: ValueKey(item.id),
              child: ListTile(
                leading: Icon(
                  Icons.square,
                  color: item.color,
                ),
                trailing: Text(item.quantity.toString()),
                title: Text(item.name),
              ),
            );
          }),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(onPressed: _addNewItem, icon: const Icon(Icons.add))
        ],
      ),
      body: content,
    );
  }
}
