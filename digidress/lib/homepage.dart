import 'package:flutter/material.dart';
import 'avatar.dart'; // Ensure you import the AvatarPage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<bool> likedPosts = List.filled(10, false); // Track like status for 10 posts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the back button
        title: Text('Digidress'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: 10, // display 10 posts as an example
        itemBuilder: (context, index) {
          return _buildPostItem(index);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Wardrobe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0, // Index of the "Home" screen
        onTap: (index) {
          if (index == 2) {
            // Navigate to Avatar Page when Wardrobe button is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AvatarPage()),
            );
          } else {
            // Handle other tabs
          }
        },
        backgroundColor: Colors.black, 
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildPostItem(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/avatar.jpg'), // Replace with user's avatar image
              ),
              SizedBox(width: 10),
              Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 10),
          Image.asset('assets/post${index + 1}.jpg'), // Display post image
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  likedPosts[index] ? Icons.favorite : Icons.favorite_border,
                  color: likedPosts[index] ? Colors.red : null,
                ),
                onPressed: () {
                  setState(() {
                    likedPosts[index] = !likedPosts[index];
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: () {
                  // Handle comment
                },
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  // Handle share
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Liked by user and others'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('View all comments'),
          ),
        ],
      ),
    );
  }
}