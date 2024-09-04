import 'package:flutter/material.dart';
import 'bottomnav.dart'; // Import the BottomNavBar widget

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _currentIndex = 3; // Set the current index for the ChatPage

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('A'),
            ),
            title: Text('Alice'),
            subtitle: Text('Hey, how are you?'),
            onTap: () {
              // Handle tap on chat item
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text('B'),
            ),
            title: Text('Bob'),
            subtitle: Text('Are we still on for today?'),
            onTap: () {
              // Handle tap on chat item
            },
          ),
          // Add more ListTiles for other chat items
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}