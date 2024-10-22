import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'clothingitem.dart';
import 'clothingmanager.dart';

class EditClothingPage extends StatefulWidget {
  final ClothingItem clothingItem;

  const EditClothingPage({
    required this.clothingItem,
    super.key,
  });

  @override
  _EditClothingPageState createState() => _EditClothingPageState();
}

class _EditClothingPageState extends State<EditClothingPage> {
  late ClothingItem _clothingItem;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clothingItem = widget.clothingItem; // Assign the passed clothing item to a local variable.
  }

  Future<void> _updateClothingItem() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(_clothingItem.documentId)
          .update({
        'clothingType': _clothingItem.type.toString().split('.').last.toLowerCase(), // Save lowercase type
        'imageUrl': _clothingItem.imageUrl,
      });

      Navigator.pop(context, 'Item updated successfully');
    } catch (e) {
      print('Error updating item: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteClothingItem() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(_clothingItem.documentId)
          .delete();

      await FirebaseStorage.instance.refFromURL(_clothingItem.imageUrl).delete();

      Navigator.pop(context, 'Item deleted successfully');
    } catch (e) {
      print('Error deleting item: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDeleteClothingItem() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this clothing item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _deleteClothingItem();
    }
  }

  void _tryOnClothing() {
    Provider.of<ClothingManager>(context, listen: false).addClothingItem(_clothingItem);
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Clothing Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDeleteClothingItem,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.network(_clothingItem.imageUrl, height: 200),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _clothingItem.type.toString().split('.').last,
                    items: [
                      'top',
                      'dress',
                      'pants',
                      'outerwear',
                      'shoes',
                      'accessories',
                    ].map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _clothingItem.type = ClothingType.values.firstWhere(
                            (e) => e.toString().split('.').last == value);
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Clothing Type'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updateClothingItem,
                    child: const Text('Save Changes'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _tryOnClothing,
                    child: const Text('Try On'),
                  ),
                ],
              ),
            ),
    );
  }
}