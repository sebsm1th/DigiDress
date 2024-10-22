import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController usernameController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername(); // Load the current username when the widget is created
  }

  // Fetch the current username from Firestore and set it in the TextField
  Future<void> _loadCurrentUsername() async {
    if (user != null) {
      try {
        // Fetch the current username from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        String currentUsername = userDoc['username'] ?? '';

        setState(() {
          // Set the fetched username as the initial value for the TextField
          usernameController.text = currentUsername;
        });
      } catch (e) {
        print('Error loading username: $e');
      }
    }
  }

  // Function to update the username in Firestore and all friends lists
  Future<void> _updateUsername(BuildContext context, String newUsername) async {
    if (user != null) {
      try {
        // Update the user's Firestore document with the new username
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'username': newUsername});

        // Call the function to update the username in all friends lists
        await updateUsernameInFriendsLists(user!.uid, newUsername);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully')),
        );
      } catch (e) {
        print('Error updating username: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update username')),
        );
      }
    }
  }

  // Function to update the username in all userFriends subcollections
  Future<void> updateUsernameInFriendsLists(String userID, String newUsername) async {
    try {
      // Fetch all users from the 'friends' collection
      QuerySnapshot usersWithFriends = await FirebaseFirestore.instance.collection('friends').get();

      // Iterate through each user document
      for (var userDoc in usersWithFriends.docs) {
        // Access the userFriends subcollection of each user
        QuerySnapshot userFriends = await FirebaseFirestore.instance
            .collection('friends')
            .doc(userDoc.id)
            .collection('userFriends')
            .where('userID', isEqualTo: userID)  // Find where the user appears in userFriends
            .get();

        // Iterate through userFriends to update the username where found
        for (var friendDoc in userFriends.docs) {
          await FirebaseFirestore.instance
              .collection('friends')
              .doc(userDoc.id)
              .collection('userFriends')
              .doc(friendDoc.id)
              .update({'username': newUsername});
        }
      }
      print('Username updated in all friends lists.');
    } catch (e) {
      print('Error updating username in friends lists: $e');
    }
  }

  // Function to delete the user's account and all associated data
  Future<void> _deleteAccount(BuildContext context) async {
    if (user != null) {
      print('User found: ${user!.email}');

      bool loggedIn = await _showLoginForm(context);
      if (!loggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
        return;
      }

      try {
        bool confirm = await _showConfirmationDialog(context);
        if (confirm) {
          print('Deleting user data...');
          await _deleteUserData(user!.uid);

          print('Deleting user friend requests...');
          await _deleteFriendRequests(user!.uid);

          print('Deleting user friends and removing references...');
          await _deleteUserFriendsAndReferences(user!.uid);

          print('Deleting user files...');
          await _deleteUserFiles(user!.uid);

          print('Deleting user posts...');
          await _deleteUserPosts(user!.uid);

          print('Deleting user chats...');
          await _deleteUserChats(user!.uid);

          print('Deleting user account...');
          await user!.delete();

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account and data deleted successfully')),
          );
        } else {
          print('User canceled the deletion process.');
        }
      } catch (e) {
        print('Error deleting account: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting account. Please try again later.')),
        );
      }
    } else {
      print('No user currently signed in.');
    }
  }

  Future<bool> _showLoginForm(BuildContext context) async {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Re-Login to Continue'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Login'),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();

                      try {
                        // Attempt to re-login the user
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email, password: password);

                        Navigator.of(dialogContext).pop(true);
                      } catch (e) {
                        print('Error during re-login: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Login failed. Please check your credentials.')),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Account'),
              content: const Text(
                  'Are you sure you want to delete your account? This action cannot be undone.'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _deleteUserData(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }

  Future<void> _deleteFriendRequests(String userId) async {
    var sentRequests = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('from', isEqualTo: userId)
        .get();
    for (var doc in sentRequests.docs) {
      await doc.reference.delete();
    }

    var receivedRequests = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('to', isEqualTo: userId)
        .get();
    for (var doc in receivedRequests.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _deleteUserFriendsAndReferences(String userId) async {
    var userFriends = await FirebaseFirestore.instance
        .collection('friends')
        .doc(userId)
        .collection('userFriends')
        .get();

    for (var doc in userFriends.docs) {
      String friendId = doc.id;
      await FirebaseFirestore.instance
          .collection('friends')
          .doc(friendId)
          .collection('userFriends')
          .doc(userId)
          .delete();
      await doc.reference.delete();
    }
  }

  // Function to delete user files including profile pictures
  Future<void> _deleteUserFiles(String userId) async {
    try {
      // Delete profile pictures
      final profilePicRef =
          FirebaseStorage.instance.ref().child('profile_pictures/$userId');
      print('Deleting profile pictures for user: $userId');
      await _deleteFolderRecursively(profilePicRef);

      print('User files deleted successfully');
    } catch (e) {
      print('Error deleting user files: $e');
    }
  }

  // Function to delete user posts and associated files
  Future<void> _deleteUserPosts(String userId) async {
    try {
      // Delete all files under 'posts/$userId' in Firebase Storage
      final userPostsStorageRef = FirebaseStorage.instance.ref().child('posts/$userId');
      await _deleteFolderRecursively(userPostsStorageRef);

      // Query and delete all post documents where 'userId' == userId
      QuerySnapshot userPosts = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get();

      // Delete all post documents
      for (var doc in userPosts.docs) {
        await doc.reference.delete();
      }

      print('User posts and associated files deleted successfully');
    } catch (e) {
      print('Error deleting user posts: $e');
    }
  }

  // Function to delete user chats
  Future<void> _deleteUserChats(String userId) async {
    try {
      // Assuming your 'chats' collection contains chat documents where 'userIds' is an array of participant IDs
      // Adjust the field names and structure according to your actual data model
      QuerySnapshot userChats = await FirebaseFirestore.instance
          .collection('chats')
          .where('userIds', arrayContains: userId)
          .get();

      for (var doc in userChats.docs) {
        // Optionally, check if you want to delete the entire chat or just remove the user from it
        // For this example, we'll delete the entire chat document
        await doc.reference.delete();
      }

      print('User chats deleted successfully');
    } catch (e) {
      print('Error deleting user chats: $e');
    }
  }

  // Recursive function to delete folders and files in Firebase Storage
  Future<void> _deleteFolderRecursively(Reference folderRef) async {
    try {
      print('Attempting to list contents of folder: ${folderRef.fullPath}');
      ListResult result = await folderRef.listAll();

      // Delete all files in the folder
      for (Reference fileRef in result.items) {
        try {
          print('Attempting to delete file: ${fileRef.fullPath}');
          await fileRef.delete();
          print('Deleted file: ${fileRef.fullPath}');
        } catch (e) {
          print('Error deleting file ${fileRef.fullPath}: $e');
        }
      }

      // Recursively delete subfolders
      for (Reference subfolderRef in result.prefixes) {
        print('Recursively deleting subfolder: ${subfolderRef.fullPath}');
        await _deleteFolderRecursively(subfolderRef);
      }

      print('Finished deleting contents of folder: ${folderRef.fullPath}');
    } catch (e) {
      print('Error accessing folder ${folderRef.fullPath}: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Logout'),
            ),
            const SizedBox(height: 20), // Add space between buttons
            ElevatedButton(
              onPressed: () => _deleteAccount(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete Account'),
            ),
            const SizedBox(height: 20), // Add space between buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'New Username',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20), // Add space between text field and button
            ElevatedButton(
              onPressed: () {
                String newUsername = usernameController.text.trim();
                if (newUsername.isNotEmpty) {
                  _updateUsername(context, newUsername);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid username')),
                  );
                }
              },
              child: const Text('Update Username'),
            ),
          ],
        ),
      ),
    );
  }
}
