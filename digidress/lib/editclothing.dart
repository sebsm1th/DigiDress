import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditClothingPage extends StatefulWidget {
  final String imageUrl;
  final String clothingType;
  final String documentId;

  const EditClothingPage({
    required this.imageUrl,
    required this.clothingType,
    required this.documentId,
    super.key,
  });

  @override
  _EditClothingPageState createState() => _EditClothingPageState();
}

class _EditClothingPageState extends State<EditClothingPage> {
  late String _clothingType;
  late String _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clothingType = widget.clothingType;
    _imageUrl = widget.imageUrl;
  }

  

  Future<void> _updateClothingItem() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(widget.documentId)
          .update({
        'clothingType': _clothingType,
        // You can add other fields if needed
      });

      // If image needs to be updated, handle image upload and update imageUrl in Firestore here

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
      // Delete the document from Firestore
      await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(widget.documentId)
          .delete();

      // Optionally, delete the image from Firebase Storage
      await FirebaseStorage.instance.refFromURL(_imageUrl).delete();

      Navigator.pop(context, 'Item deleted successfully');
    } catch (e) {
      print('Error deleting item: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Clothing Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteClothingItem,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Display the current image
                  Image.network(_imageUrl, height: 200),
                  const SizedBox(height: 16),
                  // Dropdown or TextField for clothing type
                  // DropdownButtonFormField for clothing type
                  DropdownButtonFormField<String>(
                    value: _clothingType,
                    items: [
                      'Top',
                      'Dress',
                      'Pants',
                      'Outerwear',
                      'Shoes',
                      'Accessories',
                    ].map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _clothingType = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Clothing Type'),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updateClothingItem,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }
}
