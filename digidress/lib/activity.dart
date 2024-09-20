import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userservice.dart'; // Assuming this is the user service file we discussed earlier.

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int selectedIndex = 0; // To track which subpage is selected

  // This method returns the content for the selected subpage
  Widget getSubPageContent() {
    switch (selectedIndex) {
      case 0:
        return LikesContent();
      case 1:
        return CommentsContent();
      case 2:
        return FriendRequestsContent(); // Updated with the FriendRequestsContent page
      default:
        return LikesContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Color(0xFFFFFDF5),
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
          // Row of buttons for Likes, Comments, and Friend Requests
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 0; // Set to Likes
                  });
                },
                child: Text(
                  'Likes',
                  style: TextStyle(
                    color: selectedIndex == 0 ? Colors.blue : Colors.black,
                    fontWeight: selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 1; // Set to Comments
                  });
                },
                child: Text(
                  'Comments',
                  style: TextStyle(
                    color: selectedIndex == 1 ? Colors.blue : Colors.black,
                    fontWeight: selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 2; // Set to Friend Requests
                  });
                },
                child: Text(
                  'Friend Requests',
                  style: TextStyle(
                    color: selectedIndex == 2 ? Colors.blue : Colors.black,
                    fontWeight: selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          // Divider to visually separate the row and content
          Divider(),
          // Display the content of the selected subpage
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Likes Page Content Here'),
    );
  }
}

// CommentsContent subpage
class CommentsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Comments Page Content Here'),
    );
  }
}

// FriendRequestsContent subpage
class FriendRequestsContent extends StatefulWidget {
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

  // Get current user ID
  Future<void> _getCurrentUserID() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserID = user?.uid;
    });
  }

  // Load pending friend requests
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
        ? Center(child: CircularProgressIndicator())
        : pendingRequests.isEmpty
            ? Center(child: Text('No Pending Friend Requests'))
            : ListView.builder(
                itemCount: pendingRequests.length,
                itemBuilder: (context, index) {
                  var request = pendingRequests[index];
                  String fromUserID = request['from'];

                  // Displaying username of the requester
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(fromUserID).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Loading...'),
                        );
                      }

                      if (snapshot.hasData) {
                        var fromUser = snapshot.data;
                        return ListTile(
                          title: Text(fromUser?['username'] ?? 'Unknown User'),
                          subtitle: Text('Sent you a friend request'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (currentUserID != null) {
                                    await userService.updateFriendRequestStatus(request.id, 'accepted', currentUserID!, fromUserID);
                                    loadPendingRequests(); // Reload pending requests
                                  }
                                },
                                child: Text('Accept'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  if (currentUserID != null) {
                                    await userService.updateFriendRequestStatus(request.id, 'rejected', currentUserID!, fromUserID);
                                    loadPendingRequests(); // Reload pending requests
                                  }
                                },
                                child: Text('Reject'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListTile(
                        title: Text('User not found'),
                      );
                    },
                  );
                },
              );
  }
}
