// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'posting.dart';
// import 'bottomnav.dart';
// import 'wardrobe.dart'; // Import the wardrobe page

// class AvatarPage extends StatefulWidget {
//   const AvatarPage({super.key});

//   @override
//   _AvatarPageState createState() => _AvatarPageState();
// }

// class _AvatarPageState extends State<AvatarPage> {
//   File? _imageFile;
//   final ImagePicker _picker = ImagePicker();
//   int _currentIndex = 2; // Current index for "Wardrobe" screen

//   void _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   void _showPicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Photo Library'),
//                 onTap: () {
//                   _pickImage(ImageSource.gallery);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_camera),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   _pickImage(ImageSource.camera);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _onNavBarTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFFFDF5),
//         automaticallyImplyLeading: false,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/logo1.png',
//               height: 80,
//               width: 80,
//               fit: BoxFit.contain,
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.camera_alt),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const Posting()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Weather Info Row
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   children: [
//                     Text('Thu Aug 08', style: TextStyle(color: Colors.grey)),
//                     Text('Today', style: TextStyle(color: Colors.red)),
//                     Text('16° Partly Cloudy'),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Text('Fri Aug 09', style: TextStyle(color: Colors.grey)),
//                     Text('8° Rainy'),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Text('Sat Aug 10', style: TextStyle(color: Colors.grey)),
//                     Text('18° Sunny'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
          
//           // Avatar and Outfit Controls
//           Expanded(
//             child: Center(
//               child: Column(
//                 children: [
//                   // Your Avatar
//                   Expanded(
//                     child: Image.asset('assets/transparent.png'), // Replace with actual avatar widget
//                   ),

//                   // Outfit Controls
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.arrow_back),
//                         onPressed: () {
//                           // Previous Outfit
//                         },
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           // Generate Outfit
//                         },
//                         child: const Text('Generate Outfit'),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.arrow_forward),
//                         onPressed: () {
//                           // Next Outfit
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.menu), // Drawer icon
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const WardrobePage()),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           // Bottom Navigation Bar
//           BottomNavBar(
//             currentIndex: _currentIndex,
//             onTap: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'posting.dart';
// import 'bottomnav.dart';
// import 'wardrobe.dart';
// import 'clothingitem.dart'; // Import the ClothingItem class.

// class AvatarPage extends StatefulWidget {
//   const AvatarPage({super.key});

//   @override
//   _AvatarPageState createState() => _AvatarPageState();
// }

// class _AvatarPageState extends State<AvatarPage> {
//   File? _imageFile;
//   final ImagePicker _picker = ImagePicker();
//   int _currentIndex = 2; // Current index for "Wardrobe" screen

//   // List of clothing items for the avatar.
//   final List<ClothingItem> _clothingItems = [
//     ClothingItem(
//       imagePath: 'assets/dress2.png',
//       scale: 1.0, // Keep scale at 1.0 for fixed size.
//       rotation: 0.0, // Initial rotation.
//       type: ClothingType.dress, // Specify clothing type.
//     ),
//     // Add more clothing items as needed.
//   ];

//   void _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   void _showPicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Photo Library'),
//                 onTap: () {
//                   _pickImage(ImageSource.gallery);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_camera),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   _pickImage(ImageSource.camera);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _updateClothingAnchorPoint(int index, Offset newPoint) {
//     setState(() {
//       _clothingItems[index].updateAnchorPoint(newPoint);
//     });
//   }

//   void _onNavBarTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFFFDF5),
//         automaticallyImplyLeading: false,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/logo1.png',
//               height: 80,
//               width: 80,
//               fit: BoxFit.contain,
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.camera_alt),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const Posting()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Weather Info Row
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   children: [
//                     Text('Thu Aug 08', style: TextStyle(color: Colors.grey)),
//                     Text('Today', style: TextStyle(color: Colors.red)),
//                     Text('16° Partly Cloudy'),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Text('Fri Aug 09', style: TextStyle(color: Colors.grey)),
//                     Text('8° Rainy'),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Text('Sat Aug 10', style: TextStyle(color: Colors.grey)),
//                     Text('18° Sunny'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Center(
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         Transform.scale(
//                           scale: 1.4, // Adjust this value as needed to scale the avatar size.
//                           child: Image.asset(
//                             'assets/test.png', // Mannequin image.
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                         // Use the ClothingItem's buildWidget method to display clothing items.
//                         ..._clothingItems.map(
//                           (clothingItem) => clothingItem.buildWidget(),
//                         ).toList(),
//                       ],
//                     ),
//                   ),
//                   // Outfit Controls
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.arrow_back),
//                         onPressed: () {
//                           // Previous Outfit
//                         },
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           // Generate Outfit
//                         },
//                         child: const Text('Generate Outfit'),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.arrow_forward),
//                         onPressed: () {
//                           // Next Outfit
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.menu), // Drawer icon
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const WardrobePage()),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Bottom Navigation Bar
//           BottomNavBar(
//             currentIndex: _currentIndex,
//             onTap: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'posting.dart';
import 'bottomnav.dart';
import 'wardrobe.dart';
import 'clothingitem.dart'; // Import the ClothingItem class.

class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  _AvatarPageState createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  int _currentIndex = 2; // Current index for "Wardrobe" screen

  // List of clothing items for the avatar.
  final List<ClothingItem> _clothingItems = [
    ClothingItem(
      imagePath: 'assets/flare.png',
      scale: 1.0, // Keep scale at 1.0 for initial size.
      rotation: 0.0, // Initial rotation.
      type: ClothingType.pants, // Specify clothing type.
    ),
    ClothingItem(
      imagePath: 'assets/dress.png',
      scale: 1.0, // Keep scale at 1.0 for initial size.
      rotation: 0.0, // Initial rotation.
      type: ClothingType.dress, // Specify clothing type.
    ),

    // Add more clothing items as needed.
  ];

  void _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateClothingAnchorPoint(int index, Offset newPoint) {
    setState(() {
      _clothingItems[index].updateAnchorPoint(newPoint);
    });
  }

  // Function to increase the scale of a clothing item.
  void _increaseScale(int index) {
    setState(() {
      _clothingItems[index].updateScale(_clothingItems[index].scale + 0.03);
    });
  }

  // Function to decrease the scale of a clothing item.
  void _decreaseScale(int index) {
    setState(() {
      _clothingItems[index].updateScale(_clothingItems[index].scale - 0.03);
    });
  }

  // Function to increase the rotation of a clothing item.
  void _increaseRotation(int index) {
    setState(() {
      double newRotation = _clothingItems[index].rotation + 2.5; // Increment by 2.5 degrees
      _clothingItems[index].updateRotation(newRotation); // Update the rotation
    });
  }

  // Function to decrease the rotation of a clothing item.
  void _decreaseRotation(int index) {
    setState(() {
      double newRotation = _clothingItems[index].rotation - 2.5; // Decrement by 2.5 degrees
      _clothingItems[index].updateRotation(newRotation); // Update the rotation
    });
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF5),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo1.png',
              height: 80,
              width: 80,
              fit: BoxFit.contain,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Posting()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Weather Info Row
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text('Thu Aug 08', style: TextStyle(color: Colors.grey)),
                    Text('Today', style: TextStyle(color: Colors.red)),
                    Text('16° Partly Cloudy'),
                  ],
                ),
                Column(
                  children: [
                    Text('Fri Aug 09', style: TextStyle(color: Colors.grey)),
                    Text('8° Rainy'),
                  ],
                ),
                Column(
                  children: [
                    Text('Sat Aug 10', style: TextStyle(color: Colors.grey)),
                    Text('18° Sunny'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: 1.4, // Adjust this value as needed to scale the avatar size.
                          child: Image.asset(
                            'assets/test.png', // Mannequin image.
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Use the ClothingItem's buildWidget method to display clothing items.
                        ..._clothingItems.asMap().entries.map((entry) {
                          int index = entry.key;
                          ClothingItem clothingItem = entry.value;
                          return Positioned(
                            left: clothingItem.anchorPoint.dx,
                            top: clothingItem.anchorPoint.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                _updateClothingAnchorPoint(
                                  index,
                                  clothingItem.anchorPoint + details.delta,
                                );
                              },
                              child: clothingItem.buildWidget(),
                            ),
                          );
                        }).toList(),
                        // Scale and rotation buttons for each clothing item, positioned to the side
                        Positioned(
                          right: 16.0, // Adjust as needed
                          top: 100.0, // Adjust as needed
                          child: Column(
                            children: _clothingItems.asMap().entries.map((entry) {
                              int index = entry.key;
                              return Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(_clothingItems[index].type.toString().split('.').last),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          //if (_clothingItems[index].isSelected) {
                                            _increaseScale(index);
                                          //}
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          //if (_clothingItems[index].isSelected) {
                                            _decreaseScale(index);
                                          //}
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 20), // Space between scale and rotation buttons
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.rotate_right),
                                        onPressed: () {
                                          //if (_clothingItems[index].isSelected) {
                                            _increaseRotation(index);
                                          //}
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.rotate_left),
                                        onPressed: () {
                                          //if (_clothingItems[index].isSelected) {
                                            _decreaseRotation(index);
                                          //}
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Outfit Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          // Previous Outfit
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Generate Outfit
                        },
                        child: const Text('Generate Outfit'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          // Next Outfit
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu), // Drawer icon
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WardrobePage()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom Navigation Bar
          BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
