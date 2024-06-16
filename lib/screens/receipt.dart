import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easytax/main.dart';

class Receipt {
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final String imageUrl;
  final String receiptId;
  final List<dynamic> items;
  final double total;

  Receipt({
    required this.data,
    required this.createdAt,
    required this.imageUrl,
    required this.receiptId,
    required this.items,
    required this.total,
  });
}

class ReceiptScreen extends StatefulWidget {
  final Receipt receipt;

  const ReceiptScreen({Key? key, required this.receipt}) : super(key: key);

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  late List<dynamic> receiptItems;

  @override
  void initState() {
    super.initState();
    receiptItems = widget.receipt.items;
  }

  void _removeItem(int index) {
    setState(() {
      receiptItems.removeAt(index);
    });
  }

  void _saveChanges() async {
    double newTotal =
        receiptItems.fold(0, (sum, current) => sum + (current['total'] ?? 0.0));

    try {
      final response = await supabase.from('receipts').update({
        'items': receiptItems,
        'total': newTotal,
      }).eq('receipt_id', widget.receipt.receiptId);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Receipt saved successfully!"),
      ));

      Navigator.pop(context);
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content:
              const Text('Failed to save receipt. Please try again later.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        ),
      );
    }
  }

  void _deleteReceipt() async {
    try {
      await supabase
          .from('receipts')
          .delete()
          .eq('receipt_id', widget.receipt.receiptId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Receipt deleted successfully!"),
      ));
      Navigator.pop(context);
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content:
              const Text('Failed to delete receipt. Please try again later.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final formattedDate = dateFormat.format(widget.receipt.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            color: Colors.green,
            onPressed: _saveChanges,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            color: Colors.white,
            onPressed: _addNewItem,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: _deleteReceipt,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: widget.receipt.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Text(
                  formattedDate,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ...List.generate(
                  receiptItems.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      title: Text(receiptItems[i]["description"],
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        'Type: ${receiptItems[i]["type"]}, Quantity: ${receiptItems[i]["quantity"]}, Total: \$${receiptItems[i]["total"]}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.blue,
                            onPressed: () => _editItem(i),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _removeItem(i),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editItem(int index) async {
    var editedItem = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (_) => EditItemBottomSheet(
        item: receiptItems[index],
      ),
    );

    if (editedItem != null) {
      setState(() {
        receiptItems[index] = editedItem;
      });
    }
  }

  void _addNewItem() {
    setState(() {
      receiptItems.add({
        "description": "",
        "quantity": 0,
        "total": 0.0,
        "type": "food",
      });
    });
  }
}

class EditItemBottomSheet extends StatefulWidget {
  final Map<String, dynamic> item;

  const EditItemBottomSheet({Key? key, required this.item}) : super(key: key);

  @override
  _EditItemBottomSheetState createState() => _EditItemBottomSheetState();
}

class _EditItemBottomSheetState extends State<EditItemBottomSheet> {
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _totalController;
  String? _selectedType;

  final List<String> _types = [
    'room',
    'tax',
    'parking',
    'service',
    'fee',
    'delivery',
    'product',
    'food',
    'alcohol',
    'tobacco',
    'transportation',
    'fuel',
    'refund',
    'discount',
    'payment',
    'giftcard'
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.item["description"]);
    _quantityController =
        TextEditingController(text: widget.item["quantity"].toString());
    _totalController =
        TextEditingController(text: widget.item["total"].toString());
    _selectedType = widget.item['type'] ?? _types.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
          ),
          DropdownButtonFormField<String>(
            value: _selectedType,
            items: _types.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedType = newValue!;
              });
            },
            decoration: const InputDecoration(labelText: 'Type'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: "Quantity"),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _totalController,
                  decoration: const InputDecoration(labelText: "Total"),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              var updatedItem = {
                "description": _descriptionController.text,
                "quantity": int.tryParse(_quantityController.text) ?? 0,
                "total": double.tryParse(_totalController.text) ?? 0.0,
                "type": _selectedType,
              };

              Navigator.pop(context, updatedItem);
            },
            child: const Text('Update Item'),
          ),
        ],
      ),
    );
  }
}
