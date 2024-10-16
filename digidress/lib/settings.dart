import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  Future<void> _deleteAccount(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User found: ${user.email}');
      
      // Show the mini login form within the settings page for user to re-login
      bool loggedIn = await _showLoginForm(context);
      print('Login form result: $loggedIn');
      
      if (!loggedIn) {
        print('User login failed or was canceled.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
        );
        return;
      }

      try {
        bool confirm = await _showConfirmationDialog(context);
        print('User confirmed deletion: $confirm');

        if (confirm) {
          print('Deleting user data...');
          await _deleteUserData(user.uid);

          print('Deleting user friend requests...');
          await _deleteFriendRequests(user.uid);

          print('Deleting user friends and removing references...');
          await _deleteUserFriendsAndReferences(user.uid);

          print('Deleting user files...');
          await _deleteUserFiles(user.uid);

          print('Deleting user posts');
          await _deleteUserPosts(user.uid);

          print('Deleting user account...');
          await user.delete();

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account and data deleted successfully')),
          );
        } else {
          print('User canceled the deletion process.');
        }
      } catch (e) {
        print('Error deleting account: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account. Please try again later.')),
        );
      }
    } else {
      print('No user currently signed in.');
    }
  }

  Future<bool> _showLoginForm(BuildContext context) async {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Re-Login to Continue'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
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
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: Text('Login'),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();

                  try {
                    // Attempt to re-login the user
                    UserCredential userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(email: email, password: password);
                    print('Login successful.');
                    Navigator.of(dialogContext).pop(true);
                  } catch (e) {
                    print('Login failed: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login failed. Please check your credentials.')),
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
    print('Confirmation dialog opened.');
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                print('User canceled account deletion.');
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                print('User confirmed account deletion.');
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _deleteUserData(String userId) async {
    print('Deleting Firestore data for user: $userId');
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }

  Future<void> _deleteFriendRequests(String userId) async {
    print('Deleting friend requests for user: $userId');
    
    // Delete friend requests sent by the user
    var sentRequests = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('from', isEqualTo: userId)
        .get();
    for (var doc in sentRequests.docs) {
      await doc.reference.delete();
    }
    
    // Delete friend requests received by the user
    var receivedRequests = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('to', isEqualTo: userId)
        .get();
    for (var doc in receivedRequests.docs) {
      await doc.reference.delete();
    }

    print('Deleted all friend requests for user: $userId');
  }

  Future<void> _deleteUserFriendsAndReferences(String userId) async {
    print('Deleting userFriends subcollection and removing user from friends lists: $userId');
    
    // Get the user's friends
    var userFriends = await FirebaseFirestore.instance
        .collection('friends')
        .doc(userId)
        .collection('userFriends')
        .get();

    // Delete each friend in the user's own friends list
    for (var doc in userFriends.docs) {
      // Remove the user from their friend's userFriends list
      String friendId = doc.id;
      await FirebaseFirestore.instance
          .collection('friends')
          .doc(friendId)
          .collection('userFriends')
          .doc(userId)
          .delete();

      // Delete the friend from the user's friends list
      await doc.reference.delete();
    }

    print('Deleted all friends and references for user: $userId');
  }

  Future<void> _deleteUserFiles(String userId) async {
    print('Deleting Firebase Storage files for user: $userId');
    final profilePicRef = FirebaseStorage.instance.ref().child('profile_pictures/$userId');
    final postsRef = FirebaseStorage.instance.ref().child('posts/$userId');

    await _deleteFolderRecursively(profilePicRef);
    await _deleteFolderRecursively(postsRef);
  }

  Future<void> _deleteUserPosts(String userId) async {
    print('Deleting FireStore posts');
    await FirebaseFirestore.instance.collection('posts').doc(userId).delete();
  }

  Future<void> _deleteFolderRecursively(Reference folderRef) async {
    ListResult result = await folderRef.listAll();
    for (Reference fileRef in result.items) {
      print('Deleting file: ${fileRef.fullPath}');
      await fileRef.delete();
    }
    for (Reference subfolderRef in result.prefixes) {
      print('Recursively deleting subfolder: ${subfolderRef.fullPath}');
      await _deleteFolderRecursively(subfolderRef);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _deleteAccount(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
