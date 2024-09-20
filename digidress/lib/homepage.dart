// import 'package:flutter/material.dart';
// import 'bottomnav.dart';
// import 'activity.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _currentIndex = 0;
//   List<bool> likedPosts = List.filled(10, false);
//   List<int> likeCounts = List.filled(10, 0); // List to keep track of like counts
//   List<List<Map<String, String>>> comments = List.generate(10, (_) => []);
//   String username = ''; // Variable to store the username

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsername(); // Fetch the username when the page initializes
//   }

//   // Fetch the username from Firestore using the user's UID
//   Future<void> _fetchUsername() async {
//     try {
//       String uid = FirebaseAuth.instance.currentUser!.uid;
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       setState(() {
//         username = userDoc['username'];
//       });
//     } catch (e) {
//       print('Error fetching username: $e');
//       setState(() {
//         username = 'Error';
//       });
//     }
//   }

//   void _onNavBarTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       automaticallyImplyLeading: false, // Disable the back button
//       title: const Text('Digidress'),
//       centerTitle: true,
//       backgroundColor: Colors.white,
//       actions: [
//         IconButton(
//           icon: Icon(Icons.notifications, color: Colors.black),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => ActivityPage()),
//             );
//           },
//         ),
//         const SizedBox(width: 10), // Add spacing if needed
//       ],
//     ),
//     body: ListView.builder(
//       itemCount: 10,
//       itemBuilder: (context, index) {
//         return _buildPostItem(index);
//       },
//     ),
//     bottomNavigationBar: BottomNavBar(
//       currentIndex: _currentIndex,
//       onTap: _onNavBarTap,
//     ),
//   );
// }

//   Widget _buildPostItem(int index) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SizedBox(
//         width: double.infinity, // Ensures it takes up the full width
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const CircleAvatar(
//                   radius: 20,
//                   backgroundImage: AssetImage('assets/avatar.jpg'), // Replace with user's avatar image
//                 ),
//                 const SizedBox(width: 10),
//                 Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Image.asset(
//               'assets/post${index + 1}.jpg',
//               width: double.infinity, // Ensures image takes up the full width
//               fit: BoxFit.cover, // Ensures the image maintains its aspect ratio and covers the space
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     likedPosts[index] ? Icons.favorite : Icons.favorite_border,
//                     color: likedPosts[index] ? Colors.red : null,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       likedPosts[index] = !likedPosts[index];
//                       if (likedPosts[index]) {
//                         likeCounts[index]++;
//                       } else {
//                         likeCounts[index]--;
//                       }
//                     });
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.comment),
//                   onPressed: () {
//                     _showCommentDialog(context, index);
//                   },
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Text('${likeCounts[index]} likes'), // Display the like count
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   for (var comment in comments[index])
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 4.0),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '${comment['username'] ?? 'Unknown'}:', // Display username or 'Unknown' if null
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               comment['comment'] ?? 'No comment provided', // Provide a default value for null
//                               style: TextStyle(color: Colors.grey[700]),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   // Add a tappable "View all comments" text
//                   if (comments[index].isNotEmpty) 
//                     GestureDetector(
//                       onTap: () {
//                         // Handle the tap event here
//                         _showAllComments(context, index);
//                       },
//                       child: const Text(
//                         'View all comments',
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAllComments(BuildContext context, int index) {
//     // Show a dialog or navigate to a new page with all comments
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Comments'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               for (var comment in comments[index])
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 4.0),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${comment['username'] ?? 'Unknown'}:', // Display username or 'Unknown' if null
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           comment['comment'] ?? 'No comment provided', // Provide a default value for null
//                           style: TextStyle(color: Colors.grey[700]),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showCommentDialog(BuildContext context, int index) {
//     TextEditingController commentController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Add a comment'),
//           content: TextField(
//             controller: commentController,
//             decoration: const InputDecoration(hintText: "Type your comment here"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Post'),
//               onPressed: () {
//                 setState(() {
//                   comments[index].add({
//                     'username': username, // Use the current username
//                     'comment': commentController.text,
//                   });
//                 });
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'bottomnav.dart';
import 'activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String username = ''; // Variable to store the username
  String profilePicture = '';

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // Fetch the username when the page initializes
  }

 // Fetch the current user's username and profilePicture
  Future<void> _fetchUsername() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'];
          profilePicture = userDoc['profileImageUrl'] ?? ''; // Use the profileImageUrl
        });
      } else {
        print('User document does not exist.');
      }
    } catch (e) {
      print('Error fetching username: $e');
      setState(() {
        username = 'Error';
      });
    }
  }

  // Function to fetch each post owner's profile picture
  Future<String> _fetchProfilePicture(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc['profileImageUrl'] != null) {
        return userDoc['profileImageUrl']; // Return the profile picture URL
      }
    } catch (e) {
      print('Error fetching profile picture: $e');
    }
    return ''; // Return empty string if no profile picture found
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleLike(String postId, List<dynamic> likes) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      if (likes.contains(userId)) {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  // This is the new method to add a comment to a subcollection
Future<void> _addComment(String postId, String comment) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  try {
    print('Attempting to add comment...');

    var postDocRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    var commentRef = postDocRef.collection('comments').doc(); // Subcollection reference

    // Add a new comment document to the subcollection
    await commentRef.set({
      'userId': userId,
      'username': username,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print('Comment added successfully');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Comment added successfully')),
    );
  } catch (e, stackTrace) {
    print('Error adding comment: $e');
    print('Stack trace: $stackTrace');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add comment. Please try again.')),
    );
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: Color(0xFFFFFDF5),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo1.png',
            height: 80,
            width: 80,
            fit: BoxFit.contain,
    ),
        ],
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.notifications, color: Colors.black),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ActivityPage()),
        );
      },
    ),
    const SizedBox(width: 10),
  ],
),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var posts = snapshot.data!.docs;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            var postId = post.id;
            var postData = post.data() as Map<String, dynamic>?;

            // Safely retrieve fields with null checks
            var imageUrl = postData?['imageUrl'] as String? ?? '';
            var likes = (postData?['likes'] as List<dynamic>? ?? []).map((e) => e as String).toList();
            var ownerId = postData?['userId'] as String? ?? '';

            // Fetch the post owner's username
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(ownerId).get(),
              builder: (context, ownerSnapshot) {
                if (!ownerSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                if (ownerSnapshot.hasError) {
                  return Center(child: Text('Error: ${ownerSnapshot.error}'));
                }

                var ownerData = ownerSnapshot.data!.data() as Map<String, dynamic>?;
                var ownerUsername = ownerData?['username'] as String? ?? 'Unknown';
                var ownerProfilePicture = ownerData?['profileImageUrl'] as String? ?? '';

                return _buildPostItem(postId, imageUrl, likes, ownerUsername, ownerProfilePicture);
              },
            );
          },
        );
      },
    ),
    bottomNavigationBar: BottomNavBar(
      currentIndex: _currentIndex,
      onTap: _onNavBarTap,
    ),
  );
}
  
  Widget _buildPostItem(String postId, String imageUrl, List<String> likes, String ownerUsername, String ownerProfilePicture) {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  bool isLiked = likes.contains(userId);

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
  radius: 25, // Adjust the radius as needed
  backgroundImage: ownerProfilePicture.isNotEmpty
      ? NetworkImage(ownerProfilePicture) // Fetch from Firestore if profileImageUrl exists
      : const AssetImage('assets/defaultProfilePicture.png'), // Fallback to default image
),

              const SizedBox(width: 10),
              Text(ownerUsername, style: const TextStyle(fontWeight: FontWeight.bold)), // Display owner's username
            ],
          ),
          const SizedBox(height: 10),
          Image.network(
            imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : null),
                onPressed: () => _toggleLike(postId, likes),
              ),
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: () => _showCommentDialog(context, postId),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('${likes.length} likes'),
          ),
          // StreamBuilder for the comments subcollection
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(postId)
                .collection('comments')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('No comments yet.'),
                );
              }

              var comments = snapshot.data!.docs.map((doc) {
                return doc.data() as Map<String, dynamic>;
              }).toList();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var comment in comments)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${comment['username'] ?? 'Unknown'}:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                comment['comment'] ?? 'No comment provided',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}



  void _showAllComments(BuildContext context, List<Map<String, dynamic>> comments) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Comments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var comment in comments)
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

  void _showCommentDialog(BuildContext context, String postId) {
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
            onPressed: () async {
              if (commentController.text.trim().isEmpty) {
                // Optional: Show a warning to the user
                Navigator.of(context).pop();
                return;
              }

              try {
                await _addComment(postId, commentController.text.trim());
                Navigator.of(context).pop();
              } catch (e) {
                print('Error posting comment: $e');
                // Optionally show an error message to the user
              }
            },
          ),
        ],
      );
    },
  );
}
}