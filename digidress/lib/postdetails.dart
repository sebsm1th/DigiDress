import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import 'archived.dart';

class PostDetails extends StatefulWidget {
  final String postId;
  final bool isArchived;

  const PostDetails({
    Key? key,
    required this.postId,
    this.isArchived = false, // Default to false
  }) : super(key: key);

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  DocumentSnapshot? postDetails;
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    _fetchPostDetails();
    currentUserId = _auth.currentUser?.uid ?? '';
  }

  // Fetch post details from Firestore
  Future<void> _fetchPostDetails() async {
    try {
      var postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();
      setState(() {
        postDetails = postSnapshot;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching post details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (postDetails == null) {
      return const Center(child: Text('Post not found'));
    }

    var postData = postDetails!.data() as Map<String, dynamic>?;
    var imageUrl = postData?['imageUrl'] as String? ?? '';
    var likes = (postData?['likes'] as List<dynamic>? ?? [])
        .map((e) => e as String)
        .toList();
    var ownerId = postData?['userId'] as String? ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var ownerData = snapshot.data!.data() as Map<String, dynamic>?;
        var ownerUsername = ownerData?['username'] as String? ?? 'Unknown';
        var ownerProfilePicture =
            ownerData?['profileImageUrl'] as String? ?? '';

        return Scaffold(
          appBar: AppBar(
            title: const Text(''),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: ownerProfilePicture.isNotEmpty
                            ? NetworkImage(ownerProfilePicture)
                            : const AssetImage(
                                    'assets/defaultProfilePicture.png')
                                as ImageProvider,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(ownerUsername,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'archive' && !widget.isArchived) {
                            _archivePost(widget
                                .postId); // Archive method if post is not already archived
                          } else if (value == 'unarchive' &&
                              widget.isArchived) {
                            _unarchivePost(widget
                                .postId); // Unarchive method if post is already archived
                          } else if (value == 'delete') {
                            _showDeleteConfirmationDialog(
                                widget.postId); // Show delete confirmation
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            if (!widget
                                .isArchived) // Only show 'archive' if it's not already archived
                              const PopupMenuItem<String>(
                                value: 'archive',
                                child: Text('Archive'),
                              ),
                            if (widget
                                .isArchived) // Show 'unarchive' if the post is already archived
                              const PopupMenuItem<String>(
                                value: 'unarchive',
                                child: Text('Unarchive'),
                              ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Display the post image and details
                Image.network(imageUrl,
                    width: double.infinity, fit: BoxFit.cover),
                const SizedBox(height: 10),
                _buildPostItem(ownerId, likes),
                const SizedBox(height: 10),
                _buildCommentsSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      // Check if the post is archived or not
      if (widget.isArchived) {
        // Delete the post from the 'archivedPosts' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('archivedPosts')
            .doc(postId)
            .delete();
      } else {
        // Delete the post from the 'posts' collection
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId) 
            .delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );

      // Navigate back after deletion
      Navigator.of(context).pop();
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete post')),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(String postId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete post?',
                style: TextStyle(
                  fontSize: 16.0, // Adjust size if necessary
                  color: Colors.black, // Black color for the main text
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your post will be permanently deleted. This action cannot be undone.',
                style: TextStyle(
                  fontSize: 12.0, // Smaller font for the grey text
                  color: Colors.grey, // Grey color for the secondary text
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deletePost(postId); // Call the delete method
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _archivePost(String postId) async {
    try {
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (postSnapshot.exists) {
        var postData = postSnapshot.data() as Map<String, dynamic>;

        // Move the post to the 'archivedPosts' collection under the user's profile
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('archivedPosts')
            .doc(postId)
            .set(postData);

        // Optionally, remove the post from the 'posts' collection if you want it only in archivedPosts
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({'isArchived': true}); // Mark the post as archived

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post archived successfully')));
      }
    } catch (e) {
      print('Error archiving post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to archive post')));
    }
  }

  Future<void> _unarchivePost(String postId) async {
    try {
      // Get the post data from 'archivedPosts' collection
      DocumentSnapshot archivedPostSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('archivedPosts')
          .doc(postId)
          .get();

      if (archivedPostSnapshot.exists) {
        var postData = archivedPostSnapshot.data() as Map<String, dynamic>;

        // Move the post back to 'posts' collection
        await FirebaseFirestore.instance.collection('posts').doc(postId).set({
          ...postData,
          'isArchived': false, // Set archived status to false
        });

        // Delete the post from 'archivedPosts' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('archivedPosts')
            .doc(postId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post unarchived successfully')),
        );

        // Navigate back to profile page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const ProfilePage()), // Ensure ProfilePage is defined or imported
        );
      }
    } catch (e) {
      print('Error unarchiving post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to unarchive post')),
      );
    }
  }

  // Build the post details (likes, etc.)
  Widget _buildPostItem(String ownerId, List<String> likes) {
    bool isLiked = likes.contains(currentUserId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          IconButton(
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : null),
            onPressed: () => _toggleLike(likes),
          ),
          IconButton(
            icon: const Icon(Icons.comment),
            onPressed: () => _showCommentDialog(),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('${likes.length} likes'),
        ),
      ],
    );
  }

  // Toggle like functionality
  void _toggleLike(List<String> likes) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (likes.contains(userId)) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
        'likes': FieldValue.arrayUnion([userId])
      });
    }

    _fetchPostDetails(); // Refresh post details
  }

  // Show comment dialog
  void _showCommentDialog() {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
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
              onPressed: () async {
                if (commentController.text.isNotEmpty) {
                  String userId = FirebaseAuth.instance.currentUser!.uid;
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get();
                  String username = userDoc['username'] ?? 'Unknown';

                  // Add the comment with the correct username
                  _addComment(widget.postId, commentController.text, username);
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

  // Add a comment
  Future<void> _addComment(
      String postId, String comment, String username) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
        'username': username, // Use the fetched username
      });

      _fetchPostDetails(); // Refresh post details after adding a comment
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  // Build the comments section
  Widget _buildCommentsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
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

        var comments = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: comments.map((doc) {
              var commentData = doc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${commentData['username'] ?? 'Unknown'}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        commentData['comment'] ?? 'No comment',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
