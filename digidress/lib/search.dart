// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for database
// import 'package:firebase_auth/firebase_auth.dart';  // Firebase Authentication
// import 'userservice.dart'; // Ensure this import is correct

// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   _SearchPageState createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   int _currentIndex = 1;
//   bool isLoading = false;
//   List<DocumentSnapshot> searchResults = [];

//   final UserService userService = UserService(); // Initialize userService

//   // Method to search users based on the input
//   void searchUsers(String query) async {
//     if (query.isNotEmpty) {
//       setState(() {
//         isLoading = true;
//       });

//       List<DocumentSnapshot> users = await userService.searchUsers(query); // Use the service method
//       setState(() {
//         searchResults = users;
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         searchResults = [];
//       });
//     }
//   }

//   // Get current user ID
//   Future<String?> getCurrentUserID() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     return user?.uid;
//   }

//   // Check if a friend request already exists
//   Future<bool> isFriendRequestSent(String currentUserID, String targetUserID) async {
//     return await userService.isFriendRequestAlreadySent(currentUserID, targetUserID);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('Search Page'),
//         centerTitle: true,
//         backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: searchResults.length,
//               itemBuilder: (context, index) {
//                 var user = searchResults[index];
//                 return ListTile(
//                   title: Text(user['username'] ?? 'Unknown'), // Safely access 'username'
//                   trailing: ElevatedButton(
//                     child: Text('Add Friend'),
//                     onPressed: () async {
//                       String? currentUserID = await getCurrentUserID();
//                       if (currentUserID != null) {
//                         bool alreadySent = await isFriendRequestSent(currentUserID, user.id);

//                         if (!alreadySent) {
//                           await userService.sendFriendRequest(currentUserID, user.id);

//                           // Show success message
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text('Friend request sent!'),
//                             ),
//                           );
//                         } else {
//                           // Show error message
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text('Friend request already exists!'),
//                             ),
//                           );
//                         }
//                       }
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }


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
  int _currentIndex = 1;
  bool isLoading = false;
  List<DocumentSnapshot> searchResults = [];

  final UserService userService = UserService(); // Initialize userService

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

  // Check if a friend request already exists
  Future<bool> isFriendRequestSent(String currentUserID, String targetUserID) async {
    return await userService.isFriendRequestAlreadySent(currentUserID, targetUserID);
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
                return ListTile(
                  title: Text(user['username'] ?? 'Unknown'), // Safely access 'username'
                  trailing: ElevatedButton(
                    child: Text('Add Friend'),
                    onPressed: () async {
                      String? currentUserID = await getCurrentUserID();
                      if (currentUserID != null) {
                        bool alreadySent = await isFriendRequestSent(currentUserID, user.id);

                        if (!alreadySent) {
                          await userService.sendFriendRequest(currentUserID, user.id);

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
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

