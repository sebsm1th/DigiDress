import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottomnav.dart';
import 'userservice.dart';
import 'chatroom.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _currentIndex = 3;
  List<DocumentSnapshot> _friends = [];
  bool _isLoading = true;
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  void _fetchFriends() async {
    try {
      List<DocumentSnapshot> friends = await UserService().getFriendsList(_userId);
      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching friends: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF5),
        automaticallyImplyLeading: false,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _friends.isEmpty
              ? const Center(child: Text('No friends found'))
              : ListView.builder(
                  itemCount: _friends.length,
                  itemBuilder: (context, index) {
                    final friend = _friends[index];

                    // Fetch profile data from the users collection
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(friend.id)
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage('assets/defaultProfilePicture.png'),
                            ),
                            title: Text('Loading...'),
                          );
                        }

                        final userData = snapshot.data!.data() as Map<String, dynamic>;
                        final profileImageUrl = userData['profileImageUrl'] as String? ?? '';
                        final username = userData['username'] as String? ?? 'Unknown';

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 21,
                            backgroundImage: profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : const AssetImage('assets/defaultProfilePicture.png')
                                    as ImageProvider,
                          ),
                          title: Text(username),
                          onTap: () {
                            // Navigate to the chat room with the selected friend
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoomPage(
                                  friendId: friend.id,
                                  friendName: username,
                                  friendProfileImage: profileImageUrl, // Pass the profile image URL
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
