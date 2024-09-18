import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for database
import 'package:firebase_auth/firebase_auth.dart';  // Firebase Authentication
import 'bottomnav.dart';
import 'userservice.dart'; // Make sure this import is correct

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> searchResults = [];
  bool isLoading = false;
  final userService = UserService(); // Corrected the instance creation

  // Method to search users based on the input
  void searchUsers(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      List<DocumentSnapshot> users = await userService.searchUsers(query); // Use the service method
      setState(() {
        searchResults = users;
        isLoading = false;
      });
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  // Get current user ID
  Future<String?> getCurrentUserID() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(hintText: 'Search Users'),
          onChanged: (query) {
            searchUsers(query);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var user = searchResults[index];
                return ListTile(
                  title: Text(user['username']),
                  trailing: ElevatedButton(
                    child: Text('Add Friend'),
                    onPressed: () async {
                      String? currentUserID = await getCurrentUserID();
                      if (currentUserID != null) {
                        userService.sendFriendRequest(currentUserID, user.id);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}