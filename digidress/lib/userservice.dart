import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  // Function to search users by username
  Future<List<DocumentSnapshot>> searchUsers(String query) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('username_lowercase', isGreaterThanOrEqualTo: query)
        .where('username_lowercase', isLessThanOrEqualTo: '$query\uf8ff')
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

    // Optionally, you could notify the recipient by updating their Firestore doc
    await FirebaseFirestore.instance.collection('users').doc(friendID).update({
      'newFriendRequests': true,  // Mark that a new friend request has been sent
      'hasNewActivity': true,     // Mark that there is new activity for notifications
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

  Future<void> addFriend(String currentUserID, String friendID) async {
    // Fetch the friend's username
    DocumentSnapshot friendDoc = await FirebaseFirestore.instance.collection('users').doc(friendID).get();
    String friendUsername = friendDoc['username'] ?? 'Unknown';  // Default to 'Unknown' if username is not found

    // Fetch the current user's username
    DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserID).get();
    String currentUserUsername = currentUserDoc['username'] ?? 'Unknown';  // Default to 'Unknown' if username is not found

    // Add friend to current user's friends list
    await FirebaseFirestore.instance.collection('friends').doc(currentUserID).collection('userFriends').doc(friendID).set({
      'userID': friendID,  // Add friend's user ID
      'username': friendUsername,
      'status': 'accepted',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Add current user to friend's friends list
    await FirebaseFirestore.instance.collection('friends').doc(friendID).collection('userFriends').doc(currentUserID).set({
      'userID': currentUserID,  // Add current user's ID
      'username': currentUserUsername,
      'status': 'accepted',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Function to check if two users are friends
  Future<bool> isAlreadyFriends(String currentUserID, String targetUserID) async {
    DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance
        .collection('friends')
        .doc(currentUserID)
        .collection('userFriends')
        .doc(targetUserID)
        .get();

    return friendSnapshot.exists;
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
  Future<void> updateFriendRequestStatus(String requestID, String status, String currentUserID, String friendID) async {
    // Update the friend request status
    await FirebaseFirestore.instance
        .collection('friendRequests')
        .doc(requestID)
        .update({'status': status});

    // If the request is accepted, add both users to the friends collection
    if (status == 'accepted') {
      await addFriend(currentUserID, friendID); // Ensure the addFriend method is used to update friends list
    }
  }

  // Function to get the friend count for a user
  Future<int> getFriendsCount(String userID) async {
    try {
      QuerySnapshot friendList = await FirebaseFirestore.instance
          .collection('friends')
          .doc(userID)
          .collection('userFriends')
          .get();

      return friendList.docs.length; // Return the count of friends
    } catch (e) {
      print('Error fetching friends count: $e');
      return 0; // Return 0 if there's an error
    }
  }

  // Function to fetch the list of friends
  Future<List<DocumentSnapshot>> getFriendsList(String userID) async {
    try {
      QuerySnapshot friendList = await FirebaseFirestore.instance
          .collection('friends')
          .doc(userID)
          .collection('userFriends')
          .get();

      return friendList.docs; // Return the list of friends
    } catch (e) {
      print('Error fetching friends list: $e');
      return []; // Return an empty list if there's an error
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
}