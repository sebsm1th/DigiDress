import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'clothingmanager.dart';
import 'clothingitem.dart';
import 'bottomnav.dart';
import 'wardrobe.dart';
import 'posting.dart';
import 'weatherpage.dart';

class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  _AvatarPageState createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  int _currentIndex = 2; // Current index for "Wardrobe" screen

  @override
  void initState() {
    super.initState();
    // Load clothing items from Firestore when the AvatarPage is initialized.
    //_loadClothingItemsFromFirestore();
  }

  // // Function to load clothing items from Firestore and add them to ClothingManager.
  // Future<void> _loadClothingItemsFromFirestore() async {
  //   final clothingManager = Provider.of<ClothingManager>(context, listen: false);
  //   await clothingManager.loadClothingItemsFromFirestore();
  // }

  // // Function to navigate to the wardrobe page.
  // void _onNavBarTap(int index) {
  //   setState(() {
  //     _currentIndex = index;
  //   });
  //   if (index == 1) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const WardrobePage()),
  //     );
  //   }
  // }

//   @override
//   Widget build(BuildContext context) {
//      // Listen for changes in the ClothingManager
//     final clothingItems = Provider.of<ClothingManager>(context).clothingItems;

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
//                         Positioned.fill(
//                           child: Transform.scale(
//                             scale: 1.4, // Adjust this value as needed to scale the avatar size.
//                             child: Image.asset(
//                               'assets/test.png', // Mannequin image.
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ),
//                         // Display clothing items using the ClothingManager.
//                         Consumer<ClothingManager>(
//                           builder: (context, clothingManager, child) {
//                             return Stack(
//                               children: clothingManager.clothingItems.map((item) {
//                                 return Positioned(
//                                   left: item.anchorPoint.dx,
//                                   top: item.anchorPoint.dy,
//                                   child: GestureDetector(
//                                     onPanUpdate: (details) {
//                                       // Update the anchor point using the ClothingManager.
//                                       clothingManager.updateClothingAnchorPoint(
//                                         item,
//                                         item.anchorPoint + details.delta,
//                                       );
//                                     },
//                                     child: item.buildWidget(),
//                                   ),
//                                 );
//                               }).toList(),
//                             );
//                           },
//                         ),
//                         // Scale and rotation buttons for each clothing item, positioned to the side
//                         Positioned(
//                           right: 16.0,
//                           top: 100.0,
//                           child: Consumer<ClothingManager>(
//                             builder: (context, clothingManager, child) {
//                               return Column(
//                                 children: clothingManager.clothingItems.asMap().entries.map((entry) {
//                                   ClothingItem item = entry.value;
//                                   return Row(
//                                     children: [
//                                       Column(
//                                         children: [
//                                           Text(item.type.toString().split('.').last),
//                                           IconButton(
//                                             icon: const Icon(Icons.add),
//                                             onPressed: () {
//                                               clothingManager.increaseScale(item);
//                                             },
//                                           ),
//                                           IconButton(
//                                             icon: const Icon(Icons.remove),
//                                             onPressed: () {
//                                               clothingManager.decreaseScale(item);
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(width: 20),
//                                       Column(
//                                         children: [
//                                           IconButton(
//                                             icon: const Icon(Icons.rotate_right),
//                                             onPressed: () {
//                                               clothingManager.increaseRotation(item);
//                                             },
//                                           ),
//                                           IconButton(
//                                             icon: const Icon(Icons.rotate_left),
//                                             onPressed: () {
//                                               clothingManager.decreaseRotation(item);
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   );
//                                 }).toList(),
//                               );
//                             },
//                           ),
//                         ),
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
//                       // Reset Button to clear all clothing items
//                       IconButton(
//                         icon: const Icon(Icons.clear), // Icon for reset
//                         onPressed: () {
//                           // Clear all clothing items from the avatar
//                           Provider.of<ClothingManager>(context, listen: false).clearAll();
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

// @override
// Widget build(BuildContext context) {
//   // Listen for changes in the ClothingManager
//   final clothingItems = Provider.of<ClothingManager>(context).clothingItems;

//   return Scaffold(
//     appBar: AppBar(
//       backgroundColor: const Color(0xFFFFFDF5),
//       automaticallyImplyLeading: false,
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset(
//             'assets/logo1.png',
//             height: 80,
//             width: 80,
//             fit: BoxFit.contain,
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.camera_alt),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const Posting()),
//             );
//           },
//         ),
//       ],
//     ),
//     body: Column(
//       children: [
//         // Weather Info Row
//         Container(
//           padding: const EdgeInsets.all(16.0),
//           child: const Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 children: [
//                   Text('Thu Aug 08', style: TextStyle(color: Colors.grey)),
//                   Text('Today', style: TextStyle(color: Colors.red)),
//                   Text('16° Partly Cloudy'),
//                 ],
//               ),
//               Column(
//                 children: [
//                   Text('Fri Aug 09', style: TextStyle(color: Colors.grey)),
//                   Text('8° Rainy'),
//                 ],
//               ),
//               Column(
//                 children: [
//                   Text('Sat Aug 10', style: TextStyle(color: Colors.grey)),
//                   Text('18° Sunny'),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         // Positioning the buttons below the weather row
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             children: [
//               // Left Column for Scaling Buttons
//               Expanded(
//                 child: Consumer<ClothingManager>(
//                   builder: (context, clothingManager, child) {
//                     return Column(
//                       children: clothingManager.clothingItems.map((item) {
//                         return Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.add, size: 16),
//                               onPressed: () {
//                                 clothingManager.increaseScale(item);
//                               },
//                             ),
//                             Text(
//                               item.type.toString().split('.').last, // Clothing type name
//                               style: const TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.remove, size: 16),
//                               onPressed: () {
//                                 clothingManager.decreaseScale(item);
//                               },
//                             ),
//                           ],
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//               ),
//               // Right Column for Rotation Buttons
//               Expanded(
//                 child: Consumer<ClothingManager>(
//                   builder: (context, clothingManager, child) {
//                     return Column(
//                       children: clothingManager.clothingItems.map((item) {
//                         return Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.rotate_right, size: 16),
//                               onPressed: () {
//                                 clothingManager.increaseRotation(item);
//                               },
//                             ),
//                             Text(
//                               item.type.toString().split('.').last, // Clothing type name
//                               style: const TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.rotate_left, size: 16),
//                               onPressed: () {
//                                 clothingManager.decreaseRotation(item);
//                               },
//                             ),
//                           ],
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: Center(
//             child: Column(
//               children: [
//                 Expanded(
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Positioned.fill(
//                         child: Transform.scale(
//                           scale: 1.4, // Adjust this value as needed to scale the avatar size.
//                           child: Image.asset(
//                             'assets/test.png', // Mannequin image.
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                       // Display clothing items using the ClothingManager.
//                       Consumer<ClothingManager>(
//                         builder: (context, clothingManager, child) {
//                           return Stack(
//                             children: clothingManager.clothingItems.map((item) {
//                               return Positioned(
//                                 left: item.anchorPoint.dx,
//                                 top: item.anchorPoint.dy,
//                                 child: GestureDetector(
//                                   onPanUpdate: (details) {
//                                     // Update the anchor point using the ClothingManager.
//                                     clothingManager.updateClothingAnchorPoint(
//                                       item,
//                                       item.anchorPoint + details.delta,
//                                     );
//                                   },
//                                   child: item.buildWidget(),
//                                 ),
//                               );
//                             }).toList(),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Centered Controls
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Wardrobe Button
//                     IconButton(
//                       icon: const Icon(Icons.view_agenda), // Cupboard or drawer icon
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const WardrobePage()),
//                         );
//                       },
//                     ),
//                     const SizedBox(width: 20), // Spacing between buttons
//                     // Reset Button
//                     IconButton(
//                       icon: const Icon(Icons.refresh), // Circular refresh icon
//                       onPressed: () {
//                         // Clear all clothing items from the avatar
//                         Provider.of<ClothingManager>(context, listen: false).clearAll();
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         // Bottom Navigation Bar
//         BottomNavBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//         ),
//       ],
//     ),
//   );
// }



@override
Widget build(BuildContext context) {
  // Listen for changes in the ClothingManager
  final clothingItems = Provider.of<ClothingManager>(context).clothingItems;

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
        // Add an IconButton for weather navigation (e.g., cloud icon)
        Container(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
            icon: const Icon(Icons.sunny_snowing, size: 40, color: Colors.orange),  // Cloud icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeatherPage()),  // Navigate to WeatherPage
              );
            },
          ),
        ),
        // Positioning the buttons below the weather icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Left Column for Scaling Buttons
              Expanded(
                child: Consumer<ClothingManager>(
                  builder: (context, clothingManager, child) {
                    return Column(
                      children: clothingManager.clothingItems.map((item) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                clothingManager.increaseScale(item);
                              },
                            ),
                            Text(
                              item.type.toString().split('.').last, // Clothing type name
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                clothingManager.decreaseScale(item);
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              // Right Column for Rotation Buttons
              Expanded(
                child: Consumer<ClothingManager>(
                  builder: (context, clothingManager, child) {
                    return Column(
                      children: clothingManager.clothingItems.map((item) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.rotate_right, size: 16),
                              onPressed: () {
                                clothingManager.increaseRotation(item);
                              },
                            ),
                            Text(
                              item.type.toString().split('.').last, // Clothing type name
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.rotate_left, size: 16),
                              onPressed: () {
                                clothingManager.decreaseRotation(item);
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
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
                      Positioned.fill(
                        child: Transform.scale(
                          scale: 1.4, // Adjust this value as needed to scale the avatar size.
                          child: Image.asset(
                            'assets/test.png', // Mannequin image.
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Display clothing items using the ClothingManager.
                      Consumer<ClothingManager>(
                        builder: (context, clothingManager, child) {
                          return Stack(
                            children: clothingManager.clothingItems.map((item) {
                              return Positioned(
                                left: item.anchorPoint.dx,
                                top: item.anchorPoint.dy,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    // Update the anchor point using the ClothingManager.
                                    clothingManager.updateClothingAnchorPoint(
                                      item,
                                      item.anchorPoint + details.delta,
                                    );
                                  },
                                  child: item.buildWidget(),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Centered Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Wardrobe Button
                    IconButton(
                      icon: const Icon(Icons.view_agenda), // Cupboard or drawer icon
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WardrobePage()),
                        );
                      },
                    ),
                    const SizedBox(width: 20), // Spacing between buttons
                    // Reset Button
                    IconButton(
                      icon: const Icon(Icons.refresh), // Circular refresh icon
                      onPressed: () {
                        // Clear all clothing items from the avatar
                        Provider.of<ClothingManager>(context, listen: false).clearAll();
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