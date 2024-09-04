import 'package:flutter/material.dart';
import 'bottomnav.dart'; // Import the BottomNavBar widget

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _currentIndex = 1; // Set the current index for the SearchPage

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
      // Handle navigation here if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Page'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('User 1'),
                    subtitle: Text('Details about user 1'),
                    onTap: () {
                      // Handle tap on search result
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('User 2'),
                    subtitle: Text('Details about user 2'),
                    onTap: () {
                      // Handle tap on search result
                    },
                  ),
                  // Add more ListTiles for other search results
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}