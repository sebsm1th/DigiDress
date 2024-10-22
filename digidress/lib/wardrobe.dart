// import 'package:flutter/material.dart';
// import 'bottomnav.dart';
// import 'backgroundremover.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'editclothing.dart';

// class WardrobePage extends StatefulWidget {
//   const WardrobePage({super.key});

//   @override
//   _WardrobePageState createState() => _WardrobePageState();
// }

// class _WardrobePageState extends State<WardrobePage> {
//   int _currentIndex = 1; // Set the default index to Wardrobe tab
//   List<Map<String, dynamic>> _clothingItems = [];
  
//   @override
//   void initState() {
//     super.initState();
//     _fetchClothingItems();
//   }

//   Future<void> _fetchClothingItems() async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return;

//   print('Current user ID: ${user.uid}'); // Debugging line

//   try {
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('wardrobe')
//         .where('userId', isEqualTo: user.uid)
//         .orderBy('createdAt', descending: true)
//         .get();

//     setState(() {
//       _clothingItems = querySnapshot.docs.map((doc) {
//         print('Fetched item: ${doc.data()}'); // Debugging line
//         return {
//           'documentId': doc.id, // Include the document ID here
//           ...doc.data(), // Spread the rest of the data fields
//         };
//       }).toList();
//     });
//   } catch (e) {
//     print('Error fetching clothing items: $e');
//   }
// }




//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFFFDF5),
//         automaticallyImplyLeading: true,
//         title: Row(
//           children: [
//             Image.asset(
//               'assets/logo1.png',
//               height: 40,
//               width: 40,
//               fit: BoxFit.contain,
//             ),
//             const SizedBox(width: 8),
//             const Text('All Clothes', style: TextStyle(color: Colors.black)),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // Action to add new clothing item
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const BackgroundRemover()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search a clothing item',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onChanged: (query) {
//                 // Handle search query
//               },
//             ),
//           ),
          
//           // Clothing Categories Tabs
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   // Add more categories as needed
//                   _buildCategoryChip('All', true),
//                   _buildCategoryChip('Tops', false),
//                   _buildCategoryChip('Dresses', false),
//                   _buildCategoryChip('Pants', false),
//                   _buildCategoryChip('Outerwear', false),
//                   _buildCategoryChip('Shoes', false),
//                 ],
//               ),
//             ),
//           ),
          
//           // GridView for Clothing Items
//         Expanded(
//           child: _clothingItems.isEmpty
//               ? const Center(child: Text('No clothing items found.'))
//               : GridView.builder(
//                   padding: const EdgeInsets.all(8.0),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 8.0,
//                     mainAxisSpacing: 8.0,
//                   ),
//                   itemCount: _clothingItems.length,
//                   itemBuilder: (context, index) {
//                     final item = _clothingItems[index];
//                     return Stack(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey),
//                             borderRadius: BorderRadius.circular(8),
//                             image: DecorationImage(
//                               image: NetworkImage(item['imageUrl']),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           top: 4,
//                           right: 4,
//                           child: IconButton(
//                             icon: const Icon(Icons.edit, size: 16),
//                             onPressed: () {
//                               // Edit clothing item
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => EditClothingPage(
//                                     imageUrl: item['imageUrl'],
//                                     clothingType: item['clothingType'],
//                                     documentId: item['documentId'], // Make sure to include the documentId in your data map
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//         ),
//       ],
//     ),
//       // Bottom Navigation Bar
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//             // Handle navigation to other pages if necessary
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildCategoryChip(String label, bool isSelected) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//       child: ChoiceChip(
//         label: Text(label),
//         selected: isSelected,
//         onSelected: (bool selected) {
//           // Handle category selection
//         },
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'clothingitem.dart';
// import 'editclothing.dart';
// import 'bottomnav.dart';
// import 'backgroundremover.dart';

// class WardrobePage extends StatefulWidget {
//   const WardrobePage({super.key});

//   @override
//   _WardrobePageState createState() => _WardrobePageState();
// }

// class _WardrobePageState extends State<WardrobePage> {
//   int _currentIndex = 1; // Default index to Wardrobe tab
//   List<ClothingItem> _clothingItems = []; // Use ClothingItem instead of Map

//   @override
//   void initState() {
//     super.initState();
//     _fetchClothingItems();
//   }

//   Future<void> _fetchClothingItems() async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return;

//   try {
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('wardrobe')
//         .where('userId', isEqualTo: user.uid)
//         .orderBy('createdAt', descending: true)
//         .get();

//     print('Documents fetched: ${querySnapshot.docs.length}'); // Debugging

//     setState(() {
//       _clothingItems = querySnapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         // Check for empty or null values
//         if (data['imageUrl'] == null || data['clothingType'] == null) {
//           print('Skipping document with missing fields: ${doc.id}');
//           return null; // Skip invalid documents
//         }
//         return ClothingItem.fromMap(doc.id, data);
//       }).where((item) => item != null).cast<ClothingItem>().toList(); // Remove null items
//     });
//   } catch (e) {
//     print('Error fetching clothing items: $e');
//   }
// }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFFFDF5),
//         automaticallyImplyLeading: true,
//         title: Row(
//           children: [
//             Image.asset(
//               'assets/logo1.png',
//               height: 40,
//               width: 40,
//               fit: BoxFit.contain,
//             ),
//             const SizedBox(width: 8),
//             const Text('All Clothes', style: TextStyle(color: Colors.black)),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // Navigate to BackgroundRemover to add a new clothing item
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const BackgroundRemover()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search a clothing item',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onChanged: (query) {
//                 // Handle search functionality
//               },
//             ),
//           ),
          
//           // Clothing Categories Tabs
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   // Add more categories as needed
//                   _buildCategoryChip('All', true),
//                   _buildCategoryChip('Tops', false),
//                   _buildCategoryChip('Dresses', false),
//                   _buildCategoryChip('Pants', false),
//                   _buildCategoryChip('Outerwear', false),
//                   _buildCategoryChip('Shoes', false),
//                 ],
//               ),
//             ),
//           ),
          
//           // GridView for Clothing Items
//           Expanded(
//             child: _clothingItems.isEmpty
//                 ? const Center(child: Text('No clothing items found.'))
//                 : GridView.builder(
//                     padding: const EdgeInsets.all(8.0),
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3,
//                       crossAxisSpacing: 8.0,
//                       mainAxisSpacing: 8.0,
//                     ),
//                     itemCount: _clothingItems.length,
//                     itemBuilder: (context, index) {
//                       final item = _clothingItems[index];
//                       return Stack(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(8),
//                               image: DecorationImage(
//                                 image: NetworkImage(item.imageUrl),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             top: 4,
//                             right: 4,
//                             child: IconButton(
//                               icon: const Icon(Icons.edit, size: 16),
//                               onPressed: () {
//                                 // Navigate to EditClothingPage with the selected clothing item
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => EditClothingPage(
//                                       clothingItem: item, // Pass ClothingItem directly
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
      
//       // Bottom Navigation Bar
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//             // Handle navigation to other pages if necessary
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildCategoryChip(String label, bool isSelected) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//       child: ChoiceChip(
//         label: Text(label),
//         selected: isSelected,
//         onSelected: (bool selected) {
//           // Handle category selection
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'clothingitem.dart';
import 'editclothing.dart';
import 'bottomnav.dart';
import 'backgroundremover.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  _WardrobePageState createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  int _currentIndex = 1; // Default index to Wardrobe tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF5),
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            Image.asset(
              'assets/logo1.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text('All Clothes', style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to BackgroundRemover to add a new clothing item
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BackgroundRemover()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search a clothing item',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (query) {
                // Handle search functionality
              },
            ),
          ),
          
          // Clothing Categories Tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('All', true),
                  _buildCategoryChip('Tops', false),
                  _buildCategoryChip('Dresses', false),
                  _buildCategoryChip('Pants', false),
                  _buildCategoryChip('Outerwear', false),
                  _buildCategoryChip('Shoes', false),
                ],
              ),
            ),
          ),
          
          // Real-time Clothing Items Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('wardrobe')
                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(), // Stream of wardrobe data
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No clothing items found.'));
                }

                final clothingItems = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['imageUrl'] == null || data['clothingType'] == null) {
                    print('Skipping document with missing fields: ${doc.id}');
                    return null; // Skip invalid documents
                  }
                  return ClothingItem.fromMap(doc.id, data);
                }).where((item) => item != null).cast<ClothingItem>().toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: clothingItems.length,
                  itemBuilder: (context, index) {
                    final item = clothingItems[index];
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(item.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: () {
                              // Navigate to EditClothingPage with the selected clothing item
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditClothingPage(
                                    clothingItem: item, // Pass ClothingItem directly
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Handle navigation to other pages if necessary
          });
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          // Handle category selection
        },
      ),
    );
  }
}
