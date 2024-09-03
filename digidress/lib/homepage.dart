import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digidress'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: 10, // display 10 posts
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
          // Handle navigation
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
          Image.asset('assets/post${index + 1}.jpg'), // Display the correct post image
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.favorite_border),
                onPressed: () {
                  // Handle like
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