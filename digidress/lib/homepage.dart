import 'package:flutter/material.dart';
import 'bottomnav.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; 
  List<bool> likedPosts = List.filled(10, false); 
  List<int> likeCounts = List.filled(10, 0); // List to keep track of like counts
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
        automaticallyImplyLeading: false, // Disable the back button
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
      child: Container(
        width: double.infinity, // Ensures it takes up the full width
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
                  icon: Icon(Icons.comment),
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
                    Text(comment, style: TextStyle(color: Colors.grey[700])),
                  // Add a tappable "View all comments" text
                  if (comments[index].isNotEmpty) 
                    GestureDetector(
                      onTap: () {
                        // Handle the tap event here
                        _showAllComments(context, index);
                      },
                      child: Text(
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
          title: Text('Comments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var comment in comments[index])
                Text(comment, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
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