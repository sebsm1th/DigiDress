import 'package:flutter/material.dart';
import 'bottomnav.dart';
import 'backgroundremover.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'editclothing.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  _WardrobePageState createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  int _currentIndex = 1; // Set the default index to Wardrobe tab
  List<Map<String, dynamic>> _clothingItems = [];
  
  @override
  void initState() {
    super.initState();
    _fetchClothingItems();
  }

  Future<void> _fetchClothingItems() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  print('Current user ID: ${user.uid}'); // Debugging line

  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('wardrobe')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      _clothingItems = querySnapshot.docs.map((doc) {
        print('Fetched item: ${doc.data()}'); // Debugging line
        return {
          'documentId': doc.id, // Include the document ID here
          ...doc.data(), // Spread the rest of the data fields
        };
      }).toList();
    });
  } catch (e) {
    print('Error fetching clothing items: $e');
  }
}




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
              // Action to add new clothing item
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
                // Handle search query
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
                  // Add more categories as needed
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
          
          // GridView for Clothing Items
        Expanded(
          child: _clothingItems.isEmpty
              ? const Center(child: Text('No clothing items found.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _clothingItems.length,
                  itemBuilder: (context, index) {
                    final item = _clothingItems[index];
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(item['imageUrl']),
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
                              // Edit clothing item
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditClothingPage(
                                    imageUrl: item['imageUrl'],
                                    clothingType: item['clothingType'],
                                    documentId: item['documentId'], // Make sure to include the documentId in your data map
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
