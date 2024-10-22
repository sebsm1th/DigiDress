import 'package:digidress/friendsprofilepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'bottomnav.dart';
import 'activity.dart';
import 'userservice.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String username = '';
  String profilePicture = '';
  List<String> friendsUserIds = [];
  bool isLoading = true;
  List<DocumentSnapshot> friendPosts = []; // Store posts from friends
  bool _hasFetchedFriends = false;
  bool hasNewActivity = false; // To track if there is new activity
  String? currentUserId;

  bool newLikesActivity = false;
  bool newCommentsActivity = false;
  bool newFriendRequestsActivity = false;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _initializeData();
    _listenForNewActivity(); // Start listening for new activity
  }

  Future<void> _initializeData() async {
    await _fetchUsername();
    await _fetchFriendsPosts();
    await _getFriendsPosts(); // Fetch friends' posts after fetching friends
  }

  Future<void> _fetchUsername() async {
    try {
      setState(() {
        isLoading = true;
      });

      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) return;

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'];
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchFriendsPosts() async {
    if (_hasFetchedFriends) return;

    try {
      setState(() {
        isLoading = true;
      });

      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) return;

      List<DocumentSnapshot> friendsDocs =
          await UserService().getFriendsList(uid);
      setState(() {
        friendsUserIds =
            friendsDocs.map((doc) => doc['userID'] as String).toList();
        _hasFetchedFriends = true;
      });
    } catch (e) {
      print('Error fetching friends posts: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getFriendsPosts() async {
    // Clear previous posts
    friendPosts.clear();
    for (String friendId in friendsUserIds) {
      var postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: friendId)
          .where('isArchived', isEqualTo: false)
          .get();

      // Add the fetched posts to the friendPosts list
      friendPosts.addAll(postsSnapshot.docs);
    }
    setState(() {}); // Update the UI after fetching posts
  }

  // Listening for new activity from Firestore
  void _listenForNewActivity() {
    if (currentUserId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          setState(() {
            hasNewActivity = doc.data()?['hasNewActivity'] ?? false;
            newLikesActivity = doc.data()?['newLikes']?.isNotEmpty ?? false;
            newCommentsActivity =
                doc.data()?['newComments']?.isNotEmpty ?? false;
            newFriendRequestsActivity =
                doc.data()?['newFriendRequests'] ?? false;
          });
        }
      });
    }
  }

  // Clear the notification when the user checks ActivityPage
  void _clearNewActivity() async {
    if (currentUserId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'hasNewActivity': false,
        'newLikes': [],
        'newComments': [],
        'newFriendRequests': false,
      });
      setState(() {
        hasNewActivity = false;
        newLikesActivity = false;
        newCommentsActivity = false;
        newFriendRequestsActivity = false;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFFDF5),
      automaticallyImplyLeading: false,
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
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityPage(
                      newLikesActivity: newLikesActivity,
                      newCommentsActivity: newCommentsActivity,
                      newFriendRequestsActivity: newFriendRequestsActivity,
                    ),
                  ),
                ).then((_) => _clearNewActivity()); // Clear notification when user views ActivityPage
              },
            ),
            if (hasNewActivity)
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 8,
                    minHeight: 8,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 10),
      ],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : friendPosts.isEmpty
            ? const Center(
                child: Text(
                  'No posts available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: friendPosts.length,
                itemBuilder: (context, index) {
                  var post = friendPosts[index];
                  var postId = post.id;
                  var postData = post.data() as Map<String, dynamic>?;

                  var imageUrl = postData?['imageUrl'] as String? ?? '';
                  var likes = (postData?['likes'] as List<dynamic>? ?? [])
                      .map((e) => e as String)
                      .toList();
                  var ownerId = postData?['userId'] as String? ?? '';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(ownerId)
                        .get(),
                    builder: (context, ownerSnapshot) {
                      if (!ownerSnapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      var ownerData = ownerSnapshot.data!.data() as Map<String, dynamic>?;

                      var ownerUsername = ownerData?['username'] as String? ?? 'Unknown';
                      var ownerProfilePicture = ownerData?['profileImageUrl'] as String? ?? '';

                      return _buildPostItem(
                        postId,
                        imageUrl,
                        likes,
                        ownerUsername,
                        ownerProfilePicture,
                        ownerId, // Pass ownerId here
                      );
                    },
                  );
                },
              ),
    bottomNavigationBar: BottomNavBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
    ),
  );
}


  // Updated _buildPostItem function with clickable usernames
  Widget _buildPostItem(
    String postId,
    String imageUrl,
    List<String> likes,
    String ownerUsername,
    String ownerProfilePicture,
    String ownerId,
  ) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

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
                  radius: 25,
                  backgroundImage: ownerProfilePicture.isNotEmpty
                      ? NetworkImage(ownerProfilePicture)
                      : const AssetImage('assets/defaultProfilePicture.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    // Navigate to FriendProfilePage when username is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendProfilePage(userID: ownerId),
                      ),
                    );
                  },
                  child: Text(
                    ownerUsername,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover),
            // StreamBuilder for likes
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var postData = snapshot.data!.data() as Map<String, dynamic>?;
                var updatedLikes = (postData?['likes'] as List<dynamic>? ?? [])
                    .map((e) => e as String)
                    .toList();
                bool isLiked = updatedLikes.contains(userId);

                return Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: () => _toggleLike(postId, updatedLikes),
                    ),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () => _showCommentDialog(context, postId),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('No likes yet.'),
                    );
                  }
                  var postData = snapshot.data!.data() as Map<String, dynamic>?;
                  var updatedLikesCount =
                      (postData?['likes'] as List<dynamic>? ?? []).length;

                  return Text('$updatedLikesCount likes');
                },
              ),
            ),
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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

  void _showCommentDialog(BuildContext context, String postId) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a Comment'),
          content: TextField(
            controller: commentController,
            decoration:
                const InputDecoration(hintText: 'Type your comment here...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  _addComment(postId, commentController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addComment(String postId, String comment) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String username = this.username;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
      'username': username,
    });

    var postOwnerId =
        (await FirebaseFirestore.instance.collection('posts').doc(postId).get())
            .data()?['userId'];

    if (postOwnerId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(postOwnerId)
          .update({
        'newComments': FieldValue.arrayUnion([
          {
            'postId': postId,
            'commentedBy': userId,
            'comment': comment,
          }
        ]),
        'hasNewActivity': true, // Mark new activity
      });
    }
  }

  void _toggleLike(String postId, List<dynamic> likes) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      if (likes.contains(userId)) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({
          'likes': FieldValue.arrayUnion([userId])
        });

        // Notify post owner about new like
        var postOwnerId = (await FirebaseFirestore.instance
                .collection('posts')
                .doc(postId)
                .get())
            .data()?['userId'];
        if (postOwnerId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(postOwnerId)
              .update({
            'newLikes': FieldValue.arrayUnion([
              {
                'postId': postId,
                'likedBy': userId,
              }
            ]),
            'hasNewActivity': true, // Mark new activity
          });
        }
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }
}
