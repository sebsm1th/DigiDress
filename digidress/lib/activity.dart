import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userservice.dart';

class ActivityPage extends StatefulWidget {
  final bool newLikesActivity;
  final bool newCommentsActivity;
  final bool newFriendRequestsActivity;

  const ActivityPage({
    super.key,
    required this.newLikesActivity,
    required this.newCommentsActivity,
    required this.newFriendRequestsActivity,
  });

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int selectedIndex = 0;

  // This method returns the content for the selected subpage
  Widget getSubPageContent() {
    switch (selectedIndex) {
      case 0:
        return const LikesContent();
      case 1:
        return const CommentsContent();
      case 2:
        return const FriendRequestsContent();
      default:
        return const LikesContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF5),
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
      ),
      body: Column(
        children: [
          // Row of buttons for Likes, Comments, and Friend Requests with red indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 0;
                  });
                },
                child: Stack(
                  children: [
                    Text(
                      'Likes',
                      style: TextStyle(
                        color: selectedIndex == 0 ? Colors.blue : Colors.black,
                        fontWeight: selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (widget.newLikesActivity)
                      Positioned(
                        right: -10,
                        top: -10,
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
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
                child: Stack(
                  children: [
                    Text(
                      'Comments',
                      style: TextStyle(
                        color: selectedIndex == 1 ? Colors.blue : Colors.black,
                        fontWeight: selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (widget.newCommentsActivity)
                      Positioned(
                        right: -10,
                        top: -10,
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
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 2;
                  });
                },
                child: Stack(
                  children: [
                    Text(
                      'Friend Requests',
                      style: TextStyle(
                        color: selectedIndex == 2 ? Colors.blue : Colors.black,
                        fontWeight: selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (widget.newFriendRequestsActivity)
                      Positioned(
                        right: -10,
                        top: -10,
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
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: getSubPageContent(),
          ),
        ],
      ),
    );
  }
}

// LikesContent subpage
class LikesContent extends StatelessWidget {
  const LikesContent({super.key});

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;
        var newLikes = userData?['newLikes'] as List<dynamic>? ?? [];

        if (newLikes.isEmpty) {
          return const Center(child: Text('No new likes'));
        }

        return ListView.builder(
          itemCount: newLikes.length,
          itemBuilder: (context, index) {
            var likeData = newLikes[index];
            String postId = likeData['postId'];
            String likedBy = likeData['likedBy'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(likedBy).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('Loading...'));
                }

                var user = userSnapshot.data!.data() as Map<String, dynamic>?;
                var likedByUsername = user?['username'] ?? 'Someone';

                return ListTile(
                  title: Text('$likedByUsername liked your post.'),
                );
              },
            );
          },
        );
      },
    );
  }
}

// CommentsContent subpage
class CommentsContent extends StatelessWidget {
  const CommentsContent({super.key});

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;
        var newComments = userData?['newComments'] as List<dynamic>? ?? [];

        if (newComments.isEmpty) {
          return const Center(child: Text('No new comments'));
        }

        return ListView.builder(
          itemCount: newComments.length,
          itemBuilder: (context, index) {
            var commentData = newComments[index];
            String postId = commentData['postId'];
            String commentedBy = commentData['commentedBy'];
            String comment = commentData['comment'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(commentedBy).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('Loading...'));
                }

                var user = userSnapshot.data!.data() as Map<String, dynamic>?;
                var commentedByUsername = user?['username'] ?? 'Someone';

                return ListTile(
                  title: Text('$commentedByUsername commented: $comment'),
                );
              },
            );
          },
        );
      },
    );
  }
}

// FriendRequestsContent subpage
class FriendRequestsContent extends StatefulWidget {
  const FriendRequestsContent({super.key});

  @override
  _FriendRequestsContentState createState() => _FriendRequestsContentState();
}

class _FriendRequestsContentState extends State<FriendRequestsContent> {
  final userService = UserService();
  List<DocumentSnapshot> pendingRequests = [];
  bool isLoading = true;
  String? currentUserID;

  @override
  void initState() {
    super.initState();
    _getCurrentUserID().then((_) => loadPendingRequests());
  }

  Future<void> _getCurrentUserID() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserID = user?.uid;
    });
  }

  void loadPendingRequests() async {
    if (currentUserID != null) {
      List<DocumentSnapshot> requests = await userService.getPendingFriendRequests(currentUserID!);
      setState(() {
        pendingRequests = requests;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : pendingRequests.isEmpty
            ? const Center(child: Text('No Pending Friend Requests'))
            : ListView.builder(
                itemCount: pendingRequests.length,
                itemBuilder: (context, index) {
                  var request = pendingRequests[index];
                  String fromUserID = request['from'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(fromUserID).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Loading...'),
                        );
                      }

                      if (snapshot.hasData) {
                        var fromUser = snapshot.data;
                        return ListTile(
                          title: Text(fromUser?['username'] ?? 'Unknown User'),
                          subtitle: const Text('Sent you a friend request'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (currentUserID != null) {
                                    await userService.updateFriendRequestStatus(request.id, 'accepted', currentUserID!, fromUserID);
                                    loadPendingRequests();
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Accept'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  if (currentUserID != null) {
                                    await userService.updateFriendRequestStatus(request.id, 'rejected', currentUserID!, fromUserID);
                                    loadPendingRequests();
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Reject'),
                              ),
                            ],
                          ),
                        );
                      }

                      return const ListTile(
                        title: Text('User not found'),
                      );
                    },
                  );
                },
              );
  }
}
