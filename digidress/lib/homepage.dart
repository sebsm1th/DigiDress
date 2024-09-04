import 'package:flutter/material.dart';
import 'bottomnav.dart'; // Import the BottomNavBar widget
import 'avatar.dart';
import 'profile.dart';
import 'search.dart';
import 'chat.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Current index for BottomNavBar
  List<bool> likedPosts = List.filled(10, false); 
  List<List<String>> comments = List.generate(10, (_) => []); 

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digidress'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: 10, 
        itemBuilder: (context, index) {
          return _buildPostItem(index);
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
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
                  _showCommentDialog(context, index);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var comment in comments[index]) 
                  Text(comment, style: TextStyle(color: Colors.grey[700])),
                Text('View all comments'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context, int index) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: "Type your comment here"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Post'),
              onPressed: () {
                setState(() {
                  comments[index].add(commentController.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}