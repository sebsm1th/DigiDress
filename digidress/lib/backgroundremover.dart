// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
// //import 'package:image/image.dart' as img;

// class BackgroundRemover extends StatefulWidget {
//   const BackgroundRemover({super.key});

//   @override
//   _BackgroundRemoverState createState() => _BackgroundRemoverState();
// }

// class _BackgroundRemoverState extends State<BackgroundRemover> {
//   File? _imageFile;
//   Uint8List? _processedImage;
//   final ImagePicker _picker = ImagePicker();
//   final SubjectSegmenter _segmenter = SubjectSegmenter(
//     options: SubjectSegmenterOptions(
//       enableForegroundBitmap: true,
//       enableForegroundConfidenceMask: false, // Set to false to avoid unnecessary masks
//       enableMultipleSubjects: SubjectResultOptions(
//         enableConfidenceMask: false,
//         enableSubjectBitmap: false,
//       ),
//     ),
//   );
//   bool _isLoading = false;

//   // Pick and process image
//     Future<void> _pickImage(ImageSource source) async {
//       final pickedFile = await _picker.pickImage(
//         source: source,
//         imageQuality: 75,
//         maxWidth: 800,
//         maxHeight: 800,
//       );
//       if (pickedFile != null) {
//         setState(() {
//           _imageFile = File(pickedFile.path);
//           _processedImage = null; 
//           _isLoading = true; 
//         });

//         // Use InputImage.fromFilePath instead
//         final inputImage = InputImage.fromFilePath(pickedFile.path);
//         await _removeBackground(inputImage);
//       }
//     }



//   // Process the image to remove the background
//   Future<void> _removeBackground(InputImage inputImage) async {
//     try {
//       final result = await _segmenter.processImage(inputImage);
//       print('Segmentation Results: ${result.foregroundBitmap != null}');

//       if (result.foregroundBitmap != null) {
//         setState(() {
//           _processedImage = result.foregroundBitmap;
//         });
//       } else {
//         _showError('Failed to remove the background.');
//       }
//     } catch (e) {
//       print('Error removing background: $e');
//       _showError('Error occurred while processing the image: $e'); // Include error details
//     } finally {
//       setState(() {
//         _isLoading = false; // Reset loading state
//       });
//     }
//   }


//   // Show error message
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(message),
//       backgroundColor: Colors.red,
//     ));
//   }

//   // Show picker for image selection
//   void _showPicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Photo Library'),
//                 onTap: () {
//                   _pickImage(ImageSource.gallery);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_camera),
//                 title: const Text('Camera'),
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
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Remove Background'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: _imageFile == null
//               ? const Text('No image selected.')
//               : _isLoading
//                   ? const CircularProgressIndicator()
//                   : _processedImage != null 
//                       ? Image.memory(
//                           _processedImage!,
//                           height: 500,
//                           fit: BoxFit.cover,
//                         )
//                       : const Text('Image processing failed.'),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showPicker(context),
//         child: const Icon(Icons.add_a_photo),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _segmenter.close(); // Close the segmenter to free up resources.
//     super.dispose();
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BackgroundRemover extends StatefulWidget {
  const BackgroundRemover({super.key});

  @override
  _BackgroundRemoverState createState() => _BackgroundRemoverState();
}

class _BackgroundRemoverState extends State<BackgroundRemover> {
  File? _imageFile;
  Uint8List? _processedImage;
  final ImagePicker _picker = ImagePicker();
  final SubjectSegmenter _segmenter = SubjectSegmenter(
    options: SubjectSegmenterOptions(
      enableForegroundBitmap: true,
      enableForegroundConfidenceMask: false,
      enableMultipleSubjects: SubjectResultOptions(
        enableConfidenceMask: false,
        enableSubjectBitmap: false,
      ),
    ),
  );
  bool _isLoading = false;
  String? _selectedClothingType; // Selected clothing type

  // List of clothing types for the dropdown
  final List<String> _clothingTypes = [
    'Top',
    'Bottom',
    'Dress',
    'Outerwear',
    'Accessories'
  ];

  // Pick and process image
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _processedImage = null;
        _isLoading = true;
      });

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      await _removeBackground(inputImage);
    }
  }

  // Process the image to remove the background
Future<void> _removeBackground(InputImage inputImage) async {
  try {
    final result = await _segmenter.processImage(inputImage);
    print('Segmentation Results: ${result.foregroundBitmap != null}');

    if (result.foregroundBitmap != null) {
      if (mounted) {
        setState(() {
          _processedImage = result.foregroundBitmap;
        });
      }
    } else {
      _showError('Failed to remove the background.');
    }
  } catch (e) {
    print('Error removing background: $e');
    _showError('Error occurred while processing the image: $e');
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  // Store the processed image in Firebase Storage and Firestore
  // Store image method
Future<void> _storeImage(Uint8List processedImage, String clothingType) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    _showError('User not authenticated. Please log in to save images.');
    return;
  }

  final storageRef = FirebaseStorage.instance.ref().child('wardrobe/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.png');
  try {
    await storageRef.putData(processedImage);
    final imageUrl = await storageRef.getDownloadURL();

    // Save metadata to Firestore
    await FirebaseFirestore.instance.collection('wardrobe').add({
      'userId': user.uid,
      'imageUrl': imageUrl,
      'clothingType': clothingType,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      _showSuccess('Image saved to wardrobe successfully!');
    }
  } catch (e) {
    _showError('Failed to store in database: $e');
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  // Show success message
void _showSuccess(String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: Colors.green,
  ));
}


  // Show picker for image selection
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Background'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _imageFile == null
                  ? const Text('No image selected.')
                  : _isLoading
                      ? const CircularProgressIndicator()
                      : _processedImage != null
                          ? Image.memory(
                              _processedImage!,
                              height: 300,
                              fit: BoxFit.cover,
                            )
                          : const Text('Image processing failed.'),
              const SizedBox(height: 20),
              // Dropdown for clothing type selection
              DropdownButton<String>(
                value: _selectedClothingType,
                hint: const Text('Select Clothing Type'),
                items: _clothingTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedClothingType = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_processedImage != null && _selectedClothingType != null) {
                    _storeImage(_processedImage!, _selectedClothingType!);
                  } else {
                    _showError('Please process the image and select a clothing type before saving.');
                  }
                },
                child: const Text('Save to Wardrobe'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPicker(context),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  @override
  void dispose() {
    _segmenter.close();
    super.dispose();
  }
}
