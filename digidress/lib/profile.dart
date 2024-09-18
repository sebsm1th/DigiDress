// import 'package:flutter/material.dart';
// import 'login_page.dart';
// import 'bottomnav.dart';

// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   int _currentIndex = 4; // Index of the "Profile" screen

//   void _onNavBarTap(int index) {
//     if (index != _currentIndex) {
//       setState(() {
//         _currentIndex = index;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Profile Page Placeholder',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 20), // Add some spacing between the text and the button
//             ElevatedButton(
//               onPressed: () {
//                 // Implement logout logic here
//                 // For now, just navigate back to the login screen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginPage()),
//                 );
//               },
//               child: Text('Logout'),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: _onNavBarTap,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'bottomnav.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 4; // Index of the "Profile" screen
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle navigation tap
  void _onNavBarTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user
    User? user = _auth.currentUser;

    if (user == null) {
      return Center(child: Text('Please log in to view your profile.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .where('userId', isEqualTo: user.uid) // Get posts by the logged-in user
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final posts = snapshot.data!.docs;

                  if (posts.isEmpty) {
                    return Center(child: Text('No posts yet.'));
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Show 3 posts per row
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final imageUrl = post['imageUrl'];

                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20), // Add some spacing between the posts and the button
            ElevatedButton(
              onPressed: () {
                // Log out the user and navigate back to the login screen
                _auth.signOut().then((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                });
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}