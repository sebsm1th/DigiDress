// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class Posting extends StatefulWidget {
//   @override
//   _PostingState createState() => _PostingState();
// }

// class _PostingState extends State<Posting> {
//   File? _imageFile;
//   final ImagePicker _picker = ImagePicker();

//   void _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   void _showPicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: Icon(Icons.photo_library),
//                 title: Text('Photo Library'),
//                 onTap: () {
//                   _pickImage(ImageSource.gallery);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_camera),
//                 title: Text('Camera'),
//                 onTap: () {
//                   _pickImage(ImageSource.camera);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text('Create a Post'),
//     ),
//     body: Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           _imageFile == null
//               ? Text('No image selected.')
//               : Image.file(_imageFile!),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () => _showPicker(context),
//             child: Text('Select Image'),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               // Add logic to post the image to the social feed
//             },
//             child: Text('Post'),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Posting extends StatefulWidget {
  @override
  _PostingState createState() => _PostingState();
}

class _PostingState extends State<Posting> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage() async {
  if (_imageFile == null) return;

  try {
    // Get the current user ID
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Create a reference to the Firebase Storage location
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('posts/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Upload the image
    UploadTask uploadTask = storageRef.putFile(_imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    // Save the post data in Firestore
    await FirebaseFirestore.instance.collection('posts').add({
      'userId': user.uid,
      'imageUrl': downloadUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print('Error uploading image: $e'); // Log the error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to create post.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Post'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile == null
                ? Text('No image selected.')
                : Image.file(_imageFile!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showPicker(context),
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}

