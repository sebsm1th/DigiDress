import 'package:flutter/material.dart';
import 'bottomnav.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<bool> likedPosts = List.filled(10, false);
  List<int> likeCounts = List.filled(10, 0); // List to keep track of like counts
  List<List<Map<String, String>>> comments = List.generate(10, (_) => []);
  String username = ''; // Variable to store the username

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // Fetch the username when the page initializes
  }

  // Fetch the username from Firestore using the user's UID
  Future<void> _fetchUsername() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        username = userDoc['username'];
      });
    } catch (e) {
      print('Error fetching username: $e');
      setState(() {
        username = 'Error';
      });
    }
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
        automaticallyImplyLeading: false, // Disable the back button
        title: const Text('Digidress'),
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
      child: SizedBox(
        width: double.infinity, // Ensures it takes up the full width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/avatar.jpg'), // Replace with user's avatar image
                ),
                const SizedBox(width: 10),
                Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Image.asset(
              'assets/post${index + 1}.jpg',
              width: double.infinity, // Ensures image takes up the full width
              fit: BoxFit.cover, // Ensures the image maintains its aspect ratio and covers the space
            ),
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
                      if (likedPosts[index]) {
                        likeCounts[index]++;
                      } else {
                        likeCounts[index]--;
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {
                    _showCommentDialog(context, index);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('${likeCounts[index]} likes'), // Display the like count
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var comment in comments[index])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${comment['username'] ?? 'Unknown'}:', // Display username or 'Unknown' if null
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              comment['comment'] ?? 'No comment provided', // Provide a default value for null
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Add a tappable "View all comments" text
                  if (comments[index].isNotEmpty) 
                    GestureDetector(
                      onTap: () {
                        // Handle the tap event here
                        _showAllComments(context, index);
                      },
                      child: const Text(
                        'View all comments',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllComments(BuildContext context, int index) {
    // Show a dialog or navigate to a new page with all comments
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Comments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var comment in comments[index])
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${comment['username'] ?? 'Unknown'}:', // Display username or 'Unknown' if null
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          comment['comment'] ?? 'No comment provided', // Provide a default value for null
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCommentDialog(BuildContext context, int index) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a comment'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(hintText: "Type your comment here"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Post'),
              onPressed: () {
                setState(() {
                  comments[index].add({
                    'username': username, // Use the current username
                    'comment': commentController.text,
                  });
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