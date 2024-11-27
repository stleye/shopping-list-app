import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/dummy_items.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> groceryList = [];

  void _addNewItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) {
          return const NewItem();
        },
      ),
    );
    if (newItem == null) return;
    setState(() {
      groceryList.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      groceryList.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items yet!'));

    if (groceryList.isNotEmpty) {
      content = ListView(
        children: [
          ...groceryList.map((item) {
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
