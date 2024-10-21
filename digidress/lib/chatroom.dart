// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ChatRoomPage extends StatefulWidget {
//   final String friendId;
//   final String friendName;
//   final String friendProfileImage;

//   const ChatRoomPage({
//     Key? key,
//     required this.friendId,
//     required this.friendName,
//     required this.friendProfileImage,
//   }) : super(key: key);

//   @override
//   _ChatRoomPageState createState() => _ChatRoomPageState();
// }

// class _ChatRoomPageState extends State<ChatRoomPage> {
//   final TextEditingController _messageController = TextEditingController();
//   late String _chatRoomId;
//   late String _userId;

//   @override
//   void initState() {
//     super.initState();
//     _userId = FirebaseAuth.instance.currentUser!.uid; // Get the current user ID
//     _chatRoomId = getChatRoomId(widget.friendId, _userId); // Create chat room ID
//   }

//   String getChatRoomId(String friendId, String userId) {
//     return (friendId.hashCode <= userId.hashCode)
//         ? '$friendId\_$userId'
//         : '$userId\_$friendId';
//   }

//   void _sendMessage() {
//     if (_messageController.text.isNotEmpty) {
//       FirebaseFirestore.instance
//           .collection('chats')
//           .doc(_chatRoomId)
//           .collection('messages')
//           .add({
//         'text': _messageController.text,
//         'senderId': _userId,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       _messageController.clear(); // Clear the input field after sending
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFFFDF5),
//         title: Text(widget.friendName),
//       ),
//       body: Column(
//         children: [
//           // Display the friend's profile image at the top of the chat room
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: CircleAvatar(
//               radius: 30,
//               backgroundImage: widget.friendProfileImage.isNotEmpty
//                   ? NetworkImage(widget.friendProfileImage)
//                   : const AssetImage('assets/defaultProfilePicture.png') as ImageProvider,
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chats')
//                   .doc(_chatRoomId)
//                   .collection('messages')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('No messages yet.'));
//                 }

//                 final messages = snapshot.data!.docs;

//                 return ListView.builder(
//                   reverse: true, // Show the latest messages at the bottom
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     final messageText = message['text'] ?? '';
//                     final senderId = message['senderId'];

//                     // Determine if the message was sent by the current user
//                     final isMe = senderId == _userId;

//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: isMe ? Colors.blueAccent.withOpacity(0.8) : Colors.grey.withOpacity(0.8),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           messageText,
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type your message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }  

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class ChatRoomPage extends StatefulWidget {
//   final String friendId;
//   final String friendName;
//   final String friendProfileImage;

//   const ChatRoomPage({
//     Key? key,
//     required this.friendId,
//     required this.friendName,
//     required this.friendProfileImage,
//   }) : super(key: key);

//   @override
//   _ChatRoomPageState createState() => _ChatRoomPageState();
// }

// class _ChatRoomPageState extends State<ChatRoomPage> {
//   final TextEditingController _messageController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();  // Image picker for selecting images
//   File? _selectedImage;

//   Future<void> _sendMessage(String content, String type) async {
//     String userId = FirebaseAuth.instance.currentUser!.uid;

//     if (content.trim().isNotEmpty || type == 'image') {
//       await FirebaseFirestore.instance.collection('chats').add({
//         'senderId': userId,
//         'receiverId': widget.friendId,
//         'message': content,
//         'type': type, // 'text' or 'image'
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       _messageController.clear();
//     }
//   }

//   // Function to pick an image from the gallery
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//       _uploadImage();
//     }
//   }

//   // Function to upload the selected image to Firebase Storage
//   Future<void> _uploadImage() async {
//     if (_selectedImage == null) return;

//     try {
//       String userId = FirebaseAuth.instance.currentUser!.uid;
//       Reference storageRef = FirebaseStorage.instance
//           .ref()
//           .child('chat_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
//       UploadTask uploadTask = storageRef.putFile(_selectedImage!);
//       TaskSnapshot taskSnapshot = await uploadTask;
//       String imageUrl = await taskSnapshot.ref.getDownloadURL();

//       // Send the image message
//       await _sendMessage(imageUrl, 'image');

//       setState(() {
//         _selectedImage = null; // Reset the selected image after upload
//       });
//     } catch (e) {
//       print('Error uploading image: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: widget.friendProfileImage.isNotEmpty
//                   ? NetworkImage(widget.friendProfileImage)
//                   : const AssetImage('assets/defaultProfilePicture.png') as ImageProvider,
//             ),
//             const SizedBox(width: 10),
//             Text(widget.friendName),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chats')
//                   .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                   .where('receiverId', isEqualTo: widget.friendId)
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final messages = snapshot.data!.docs;
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     final isSender = message['senderId'] == FirebaseAuth.instance.currentUser!.uid;
//                     return ListTile(
//                       title: message['type'] == 'image'
//                           ? Image.network(message['message'], height: 200)
//                           : Text(message['message']),
//                       subtitle: Text(isSender ? 'You' : widget.friendName),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.attach_file),
//                   onPressed: _pickImage,  // Paper clip icon to pick an image
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () => _sendMessage(_messageController.text, 'text'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatRoomPage extends StatefulWidget {
  final String friendId;
  final String friendName;
  final String friendProfileImage;

  const ChatRoomPage({
    Key? key,
    required this.friendId,
    required this.friendName,
    required this.friendProfileImage,
  }) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // Image picker for selecting images
  File? _selectedImage;
  late String _chatRoomId;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser!.uid; // Get the current user ID
    _chatRoomId = getChatRoomId(widget.friendId, _userId); // Create chat room ID
  }

  String getChatRoomId(String friendId, String userId) {
    return (friendId.hashCode <= userId.hashCode)
        ? '$friendId\_$userId'
        : '$userId\_$friendId';
  }

  Future<void> _sendMessage(String content, String type) async {
    if (content.trim().isNotEmpty || type == 'image') {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .add({
        'content': content,
        'senderId': _userId,
        'type': type, // 'text' or 'image'
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear(); // Clear the input field after sending
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Show preview dialog
      _showImagePreviewDialog();
    }
  }

  // Show image preview before sending
  Future<void> _showImagePreviewDialog() async {
    if (_selectedImage == null) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send this image?'),
          content: _selectedImage != null
              ? Image.file(_selectedImage!, height: 200) // Display the selected image
              : const SizedBox(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog (Cancel)
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog (Send)
                _uploadImage(); // Upload and send the image
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  // Function to upload the selected image to Firebase Storage
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images/$_userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = storageRef.putFile(_selectedImage!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Send the image message
      await _sendMessage(imageUrl, 'image');

      setState(() {
        _selectedImage = null; // Reset the selected image after upload
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF5),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.friendProfileImage.isNotEmpty
                  ? NetworkImage(widget.friendProfileImage)
                  : const AssetImage('assets/defaultProfilePicture.png') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(widget.friendName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Show the latest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageContent = message['content'] ?? '';
                    final messageType = message['type'];
                    final senderId = message['senderId'];

                    // Determine if the message was sent by the current user
                    final isMe = senderId == _userId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent.withOpacity(0.8) : Colors.grey.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: messageType == 'image'
                            ? Image.network(messageContent, height: 200)
                            : Text(
                                messageContent,
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickImage, // Button to pick an image
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text, 'text'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
