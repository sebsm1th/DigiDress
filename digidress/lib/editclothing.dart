// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'avatar.dart';
// import 'clothingitem.dart';
// import 'package:provider/provider.dart';
// import 'clothingmanager.dart';

// class EditClothingPage extends StatefulWidget {
//   final String imageUrl;
//   final String clothingType;
//   final String documentId;
  

//   const EditClothingPage({
//     required this.imageUrl,
//     required this.clothingType,
//     required this.documentId,
//     super.key,
//   });

//   @override
//   _EditClothingPageState createState() => _EditClothingPageState();
// }

// class _EditClothingPageState extends State<EditClothingPage> {
//   late String _clothingType;
//   late String _imageUrl;
//   bool _isLoading = false;
//   final List<ClothingItem> _clothingItems = [];

//   @override
//   void initState() {
//     super.initState();
//     _clothingType = widget.clothingType;
//     _imageUrl = widget.imageUrl;
//   }


//   Future<void> _updateClothingItem() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await FirebaseFirestore.instance
//           .collection('wardrobe')
//           .doc(widget.documentId)
//           .update({
//         'clothingType': _clothingType,
//         // You can add other fields if needed
//       });

//       // If image needs to be updated, handle image upload and update imageUrl in Firestore here

//       Navigator.pop(context, 'Item updated successfully');
//     } catch (e) {
//       print('Error updating item: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _deleteClothingItem() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Delete the document from Firestore
//       await FirebaseFirestore.instance
//           .collection('wardrobe')
//           .doc(widget.documentId)
//           .delete();

//       // Optionally, delete the image from Firebase Storage
//       await FirebaseStorage.instance.refFromURL(_imageUrl).delete();

//       Navigator.pop(context, 'Item deleted successfully');
//     } catch (e) {
//       print('Error deleting item: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _tryOnClothing() {
//     ClothingType clothingTypeEnum;
//     switch (_clothingType) {
//       case 'Top':
//         clothingTypeEnum = ClothingType.top;
//         break;
//       case 'Dress':
//         clothingTypeEnum = ClothingType.dress;
//         break;
//       case 'Pants':
//         clothingTypeEnum = ClothingType.pants;
//         break;
//       case 'Outerwear':
//         clothingTypeEnum = ClothingType.outerwear;
//         break;
//       case 'Shoes':
//         clothingTypeEnum = ClothingType.shoes;
//         break;
//       case 'Accessories':
//         clothingTypeEnum = ClothingType.accessories;
//         break;
//       default:
//         clothingTypeEnum = ClothingType.top; // Default value or handle error
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AvatarPage(
//           imageUrl: _imageUrl,
//           clothingType: clothingTypeEnum, // Pass the enum value
//         ),
//       ),
//     );
//   }

//   // // In EditClothingPage, when the user presses "Try On":
//   // void _tryOnClothingItem() {
//   //   // Create the ClothingItem object with the current details.
//   //   ClothingType clothingTypeEnum;
//   //   switch (_clothingType) {
//   //     case 'Top':
//   //       clothingTypeEnum = ClothingType.top;
//   //       break;
//   //     case 'Dress':
//   //       clothingTypeEnum = ClothingType.dress;
//   //       break;
//   //     case 'Pants':
//   //       clothingTypeEnum = ClothingType.pants;
//   //       break;
//   //     case 'Outerwear':
//   //       clothingTypeEnum = ClothingType.outerwear;
//   //       break;
//   //     case 'Shoes':
//   //       clothingTypeEnum = ClothingType.shoes;
//   //       break;
//   //     case 'Accessories':
//   //       clothingTypeEnum = ClothingType.accessories;
//   //       break;
//   //     default:
//   //       clothingTypeEnum = ClothingType.top; // Default value or handle error
//   //   }
//   //   final clothingItem = ClothingItem(
//   //     imageUrl: _imageUrl,
//   //     scale: 1.0, // Default or user-adjusted value.
//   //     rotation: 0.0, // Default or user-adjusted value.
//   //     type: clothingTypeEnum,
//   //   );

//   //   // Add the clothing item to the shared array.
//   //   _clothingItems.add(clothingItem);

//   //   // Navigate to the AvatarPage with the clothing items array.
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => AvatarPage(clothingItems: _clothingItems),
//   //     ),
//   //   );
//   // }





//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Clothing Item'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: _deleteClothingItem,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   // Display the current image
//                   Image.network(_imageUrl, height: 200),
//                   const SizedBox(height: 16),
//                   // Dropdown or TextField for clothing type
//                   // DropdownButtonFormField for clothing type
//                   DropdownButtonFormField<String>(
//                     value: _clothingType,
//                     items: [
//                       'Top',
//                       'Dress',
//                       'Pants',
//                       'Outerwear',
//                       'Shoes',
//                       'Accessories',
//                     ].map((type) {
//                       return DropdownMenuItem<String>(
//                         value: type,
//                         child: Text(type),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _clothingType = value!;
//                       });
//                     },
//                     decoration: const InputDecoration(labelText: 'Clothing Type'),
//                   ),

//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _updateClothingItem,
//                     child: const Text('Save Changes'),
//                   ),
//                 const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                 // Add the clothing item to the ClothingManager when 'Try On' is pressed.
//                 Provider.of<ClothingManager>(context, listen: false)
//                     .addClothingItem(clothingItem);

//                 Navigator.pop(context); // Go back to the AvatarPage.
//               },
//                     child: const Text('Try On'),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

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
      // Update the clothing item in Firestore.
      await FirebaseFirestore.instance
          .collection('wardrobe')
          .doc(_clothingItem.documentId) // Use the document ID of the clothing item.
          .update(_clothingItem.toMap()); // Convert ClothingItem to a map for Firestore.

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
      // Delete the clothing item from Firestore and Firebase Storage.
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

  void _tryOnClothing() {
    // Add the clothing item to the ClothingManager when 'Try On' is pressed.
    Provider.of<ClothingManager>(context, listen: false)
        .addClothingItem(_clothingItem);

    Navigator.pop(context); // Go back to the AvatarPage.
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
                  Image.network(_clothingItem.imageUrl, height: 200),
                  const SizedBox(height: 16),

                  // DropdownButtonFormField for clothing type
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
                        // Update the type when a new value is selected
                        _clothingItem.type = ClothingType.values.firstWhere(
                            (e) => e.toString().split('.').last == value);
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Clothing Type'),
                  ),

                  const SizedBox(height: 16),

                  // Button to save changes
                  ElevatedButton(
                    onPressed: _updateClothingItem,
                    child: const Text('Save Changes'),
                  ),

                  const SizedBox(height: 16),

                  // Button to try on clothing
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
