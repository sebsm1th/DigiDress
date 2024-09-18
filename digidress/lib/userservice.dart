import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  // Function to search users by username
  Future<List<DocumentSnapshot>> searchUsers(String query) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return result.docs;
  }

  // Function to send a friend request
  Future<void> sendFriendRequest(String currentUserID, String friendID) async {
    await FirebaseFirestore.instance.collection('friendRequests').add({
      'from': currentUserID,  // The user sending the friend request
      'to': friendID,         // The user receiving the friend request
      'status': 'pending',    // Status of the request (pending, accepted, etc.)
      'timestamp': FieldValue.serverTimestamp(),  // Timestamp for the request
    });
  }
}