import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'avatar.dart';
import 'clothingitem.dart';

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
  final List<ClothingItem> _clothingItems = [];

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

  void _tryOnClothing() {
    ClothingType clothingTypeEnum;
    switch (_clothingType) {
      case 'Top':
        clothingTypeEnum = ClothingType.top;
        break;
      case 'Dress':
        clothingTypeEnum = ClothingType.dress;
        break;
      case 'Pants':
        clothingTypeEnum = ClothingType.pants;
        break;
      case 'Outerwear':
        clothingTypeEnum = ClothingType.outerwear;
        break;
      case 'Shoes':
        clothingTypeEnum = ClothingType.shoes;
        break;
      case 'Accessories':
        clothingTypeEnum = ClothingType.accessories;
        break;
      default:
        clothingTypeEnum = ClothingType.top; // Default value or handle error
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarPage(
          imageUrl: _imageUrl,
          clothingType: clothingTypeEnum, // Pass the enum value
        ),
      ),
    );
  }

  // // In EditClothingPage, when the user presses "Try On":
  // void _tryOnClothingItem() {
  //   // Create the ClothingItem object with the current details.
  //   ClothingType clothingTypeEnum;
  //   switch (_clothingType) {
  //     case 'Top':
  //       clothingTypeEnum = ClothingType.top;
  //       break;
  //     case 'Dress':
  //       clothingTypeEnum = ClothingType.dress;
  //       break;
  //     case 'Pants':
  //       clothingTypeEnum = ClothingType.pants;
  //       break;
  //     case 'Outerwear':
  //       clothingTypeEnum = ClothingType.outerwear;
  //       break;
  //     case 'Shoes':
  //       clothingTypeEnum = ClothingType.shoes;
  //       break;
  //     case 'Accessories':
  //       clothingTypeEnum = ClothingType.accessories;
  //       break;
  //     default:
  //       clothingTypeEnum = ClothingType.top; // Default value or handle error
  //   }
  //   final clothingItem = ClothingItem(
  //     imageUrl: _imageUrl,
  //     scale: 1.0, // Default or user-adjusted value.
  //     rotation: 0.0, // Default or user-adjusted value.
  //     type: clothingTypeEnum,
  //   );

  //   // Add the clothing item to the shared array.
  //   _clothingItems.add(clothingItem);

  //   // Navigate to the AvatarPage with the clothing items array.
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AvatarPage(clothingItems: _clothingItems),
  //     ),
  //   );
  // }





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
