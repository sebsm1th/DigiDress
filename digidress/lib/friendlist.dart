// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'flutter/posting.dart';
// import 'flutter/bottomnav.dart';

// class FriendsList extends StatelessWidget 
// {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Friends')),
//       body: Column(
//         children: [
//           Expanded(child: _buildFriendsList()),
//           const Divider(),
//           Expanded(child: _buildPendingRequests()),
//         ],
//       ),
//     );
//   }

//   Widget _buildFriendsList() 
//   {
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance
//           .collection('users')
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .snapshots(),
//       builder: (context, snapshot) 
//       {
//         if (!snapshot.hasData) return const CircularProgressIndicator();
//         var friends = snapshot.data['friends'] as List;
//         return ListView.builder(
//           itemCount: friends.length,
//           itemBuilder: (context, index) 
//           {
//             return ListTile(
//               title: Text(friends[index]),
//               trailing: const Icon(Icons.person),
//             );
//           },
//         );
//       },
//     );
//   }
// //Not finished
//   Widget _buildPendingRequests() 
//   {
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance
//           .collection('users')
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .snapshots(),
//       builder: (context, snapshot) 
//       {
//         if (!snapshot.hasData) return const CircularProgressIndicator();
//         var pendingRequests = snapshot.data['pendingRequests'] as List;
//         return ListView.builder(
//           itemCount: pendingRequests.length,
//           itemBuilder: (context, index) 
//           {
//             return ListTile(
//               title: Text(pendingRequests[index]),
//               trailing: ElevatedButton(
//                 child: const Text('Accept'),
//                 onPressed: () {
//                   // Handle accepting friend request
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }