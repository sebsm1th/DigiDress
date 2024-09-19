import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  // Function to search users by username
  Future<List<DocumentSnapshot>> searchUsers(String query) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
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

  // Function to check if a friend request already exists
  Future<bool> isFriendRequestAlreadySent(String currentUserID, String targetUserID) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('from', isEqualTo: currentUserID)
        .where('to', isEqualTo: targetUserID)
        .where('status', isEqualTo: 'pending') // Check only for pending requests
        .get();

    return result.docs.isNotEmpty;
  }

  // Function to get pending friend requests for the current user
  Future<List<DocumentSnapshot>> getPendingFriendRequests(String currentUserID) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('friendRequests')
        .where('to', isEqualTo: currentUserID)
        .where('status', isEqualTo: 'pending')
        .get();

    return result.docs;
  }

  // Function to update friend request status (accept/reject)
  Future<void> updateFriendRequestStatus(String requestID, String status) async {
    await FirebaseFirestore.instance
        .collection('friendRequests')
        .doc(requestID)
        .update({'status': status});
  }
}
