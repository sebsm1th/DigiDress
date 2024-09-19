import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for database
import 'package:firebase_auth/firebase_auth.dart';  // Firebase Authentication
import 'userservice.dart'; // Ensure this import is correct

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isLoading = false;
  List<DocumentSnapshot> searchResults = [];
  String? currentUserID;

  final UserService userService = UserService(); // Initialize userService

  @override
  void initState() {
    super.initState();
    _getCurrentUserID();
  }

  // Method to get current user ID
  Future<void> _getCurrentUserID() async {
    currentUserID = FirebaseAuth.instance.currentUser?.uid;
  }

  // Method to search users based on the input
  void searchUsers(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      // Fetch search results
      List<DocumentSnapshot> users = await userService.searchUsers(query);

      // Filter out the current user from duplicates but include them in results
      List<DocumentSnapshot> filteredUsers = users
          .toSet() // Remove duplicates
          .toList();

      setState(() {
        searchResults = filteredUsers;
        isLoading = false;
      });
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  // Check if a friend request already exists
  Future<bool> isFriendRequestSent(String targetUserID) async {
    if (currentUserID != null) {
      return await userService.isFriendRequestAlreadySent(currentUserID!, targetUserID);
    }
    return false;
  }

  // Check if the current user is already friends with the target user
  Future<bool> isAlreadyFriends(String targetUserID) async {
    if (currentUserID != null) {
      return await userService.isAlreadyFriends(currentUserID!, targetUserID);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (query) {
            searchUsers(query); // Call search method on text change
          },
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var user = searchResults[index];
                bool isCurrentUser = currentUserID == user.id; // Check if the result is the current user

                return ListTile(
                  title: Text(user['username'] ?? 'Unknown'), // Safely access 'username'
                  trailing: isCurrentUser
                      ? null // If the user is viewing their own profile, don't show any button
                      : FutureBuilder<bool>(
                          future: isAlreadyFriends(user.id), // Check if already friends
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Show loading indicator while checking friendship status
                            }
                            if (snapshot.hasData && snapshot.data == true) {
                              return Text('Friends'); // Display "Friends" if they are already friends
                            } else {
                              return ElevatedButton(
                                child: Text('Add Friend'),
                                onPressed: () async {
                                  bool alreadySent = await isFriendRequestSent(user.id);

                                  if (!alreadySent) {
                                    await userService.sendFriendRequest(currentUserID!, user.id);

                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Friend request sent!'),
                                      ),
                                    );
                                  } else {
                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Friend request already exists!'),
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                          },
                        ),
                );
              },
            ),
    );
  }
}
