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