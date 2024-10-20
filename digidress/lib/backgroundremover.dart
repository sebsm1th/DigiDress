// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';

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
//       enableForegroundConfidenceMask: true,
//       enableMultipleSubjects: SubjectResultOptions(
//         enableConfidenceMask: true,
//         enableSubjectBitmap: true,
//       ),
//     ),
//   );
//   bool _isLoading = false; // Loading state

//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path); // Convert XFile to File
//         _processedImage = null; // Reset the processed image while loading
//         _isLoading = true; // Set loading state to true
//       });

//       // Compress the image before processing
//       File? compressedImage = await testCompressAndGetFile(_imageFile!, '${Directory.systemTemp.path}/temp_image.jpg');
//       if (compressedImage != null) {
//         final inputImage = InputImage.fromFilePath(compressedImage.path);
//         await _removeBackground(inputImage);
//       } else {
//         setState(() {
//           _isLoading = false; // Reset loading state if compression failed
//         });
//       }
//     }
//   }

//   Future<File?> testCompressAndGetFile(File file, String targetPath) async {
//     // Call the compression function and get the result
//     final compressedFilePath = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       quality: 88, // Adjust quality as needed
//       rotate: 180,
//     );

//     // Ensure that we get a valid File back
//     if (compressedFilePath != null) {
//       File compressedFile = File(compressedFilePath.path); // Convert to File
//       print('Original file size: ${file.lengthSync()} bytes');
//       print('Compressed file size: ${compressedFile.lengthSync()} bytes');
//       return compressedFile; // Return the compressed file
//     } else {
//       print('Compression failed');
//       return null; // Return null if compression failed
//     }
//   }

//   Future<void> _removeBackground(InputImage inputImage) async {
//     try {
//       final result = await _segmenter.processImage(inputImage);

//       // Use the foreground bitmap from the result if available
//       if (result.foregroundBitmap != null) {
//         setState(() {
//           _processedImage = result.foregroundBitmap;
//         });
//       } else {
//         setState(() {
//           _processedImage = null;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to remove the background.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error removing background: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Error occurred while processing the image.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false; // Reset loading state
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
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 _imageFile == null
//                     ? const Text('No image selected.')
//                     : _isLoading
//                         ? const CircularProgressIndicator() // Show loading only while processing
//                         : _processedImage != null 
//                             ? Image.memory(
//                                 _processedImage!,
//                                 height: 200,
//                                 fit: BoxFit.cover,
//                               )
//                             : const Text('Image processing failed.'),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () => _showPicker(context),
//                   child: const Text('Select Image'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }


//   @override
//   void dispose() {
//     _segmenter.close(); // Close the segmenter to free up resources.
//     super.dispose();
//   }
// }

// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
// import 'package:image/image.dart' as img;
// //import 'package:google_mlkit_commons/google_mlkit_commons.dart'; // Ensure this import for InputImage

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
//       enableForegroundConfidenceMask: true,
//       enableMultipleSubjects: SubjectResultOptions(
//         enableConfidenceMask: true,
//         enableSubjectBitmap: true,
//       ),
//     ),
//   );
//   bool _isLoading = false; // Loading state

//   // Resize function
//   Future<Uint8List> resizeImage(Uint8List imageBytes, {int width = 800, int height = 800}) async {
//     final originalImage = img.decodeImage(imageBytes);
//     if (originalImage == null) return imageBytes; // Return original if decoding fails

//     // Resize the image
//     final resizedImage = img.copyResize(originalImage, width: width, height: height);
//     return Uint8List.fromList(img.encodePng(resizedImage));
//   }

//   Future<void> _pickImage(ImageSource source) async {
//   final pickedFile = await _picker.pickImage(source: source, imageQuality: 75);
//   if (pickedFile != null) {
//     final bytes = await pickedFile.readAsBytes();
    
//     // Resize the image bytes
//     final resizedBytes = await resizeImage(bytes);
    
//     setState(() {
//       _imageFile = File(pickedFile.path); // Keep the original File reference
//       _processedImage = null; // Reset processed image
//       _isLoading = true; // Set loading state
//     });

//     // Create InputImage from resizedBytes
//     final inputImage = InputImage.fromBytes(
//       bytes: resizedBytes,
//       metadata: InputImageMetadata(
//         size: Size(800, 800), // Set the size to match the resized dimensions
//         rotation: InputImageRotation.rotation0deg, // Use rotation0deg for 0 degrees rotation
//         format: InputImageFormat.nv21, // Use the correct format according to your image data
//         bytesPerRow: 800, // Adjust this based on your image width
//       ),
//     );


//     // Debugging: Log input image details
//     print('Input Image Details:');
//     print('Size: ${inputImage.metadata!.size}');
//     print('Format: ${inputImage.metadata!.format}');
//     print('Bytes Per Row: ${inputImage.metadata!.bytesPerRow}');
//     print('Resized Bytes Length: ${resizedBytes.length}');

//     // Process the resized image
//     await _removeBackground(inputImage);
//   }
// }


//   Future<void> _removeBackground(InputImage inputImage) async {
//   try {
//     final result = await _segmenter.processImage(inputImage);

//     // Debugging: Log segmentation results
//     print('Segmentation Results:');
//     print('Foreground Bitmap: ${result.foregroundBitmap}');
//     print('Confidence Mask: ${result.foregroundConfidenceMask}');

//     // Use the foreground bitmap from the result if available
//     if (result.foregroundBitmap != null) {
//       setState(() {
//         _processedImage = result.foregroundBitmap;
//       });
//     } else {
//       setState(() {
//         _processedImage = null;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to remove the background.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   } catch (e) {
//     print('Error removing background: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Error occurred while processing the image.'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   } finally {
//     setState(() {
//       _isLoading = false; // Reset loading state
//     });
//   }
// }

//   void _showPicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
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
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 _imageFile == null
//                     ? const Text('No image selected.')
//                     : _isLoading
//                         ? const CircularProgressIndicator() // Show loading only while processing
//                         : _processedImage != null 
//                             ? Image.memory(
//                                 _processedImage!,
//                                 height: 200,
//                                 fit: BoxFit.cover,
//                               )
//                             : const Text('Image processing failed.'),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () => _showPicker(context),
//                   child: const Text('Select Image'),
//                 ),
//               ],
//             ),
//           ),
//         ),
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
import 'package:image/image.dart' as img;

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
      enableForegroundConfidenceMask: false, // Set to false to avoid unnecessary masks
      enableMultipleSubjects: SubjectResultOptions(
        enableConfidenceMask: false,
        enableSubjectBitmap: true,
      ),
    ),
  );
  bool _isLoading = false;

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

        // Use InputImage.fromFilePath instead
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
        setState(() {
          _processedImage = result.foregroundBitmap;
        });
      } else {
        _showError('Failed to remove the background.');
      }
    } catch (e) {
      print('Error removing background: $e');
      _showError('Error occurred while processing the image: $e'); // Include error details
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }


  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
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
          child: _imageFile == null
              ? const Text('No image selected.')
              : _isLoading
                  ? const CircularProgressIndicator()
                  : _processedImage != null 
                      ? Image.memory(
                          _processedImage!,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : const Text('Image processing failed.'),
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
    _segmenter.close(); // Close the segmenter to free up resources.
    super.dispose();
  }
}
