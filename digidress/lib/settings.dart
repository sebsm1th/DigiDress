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

    return await showDialog(
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login failed. Please check your credentials.')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
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
    ) ?? false;
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

  Future<void> _deleteUserFiles(String userId) async {
    final profilePicRef = FirebaseStorage.instance.ref().child('profile_pictures/$userId');
    final postsRef = FirebaseStorage.instance.ref().child('posts/$userId');

    await _deleteFolderRecursively(profilePicRef);
    await _deleteFolderRecursively(postsRef);
  }

  Future<void> _deleteUserPosts(String userId) async {
    await FirebaseFirestore.instance.collection('posts').doc(userId).delete();
  }

  Future<void> _deleteFolderRecursively(Reference folderRef) async {
    ListResult result = await folderRef.listAll();
    for (Reference fileRef in result.items) {
      await fileRef.delete();
    }
    for (Reference subfolderRef in result.prefixes) {
      await _deleteFolderRecursively(subfolderRef);
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
