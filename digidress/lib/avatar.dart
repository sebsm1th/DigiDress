import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'posting.dart';
import 'bottomnav.dart';
import 'wardrobe.dart'; // Import the wardrobe page

class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  _AvatarPageState createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  int _currentIndex = 2; // Current index for "Wardrobe" screen

  void _pickImage(ImageSource source) async {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Posting()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Weather Info Row
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text('Thu Aug 08', style: TextStyle(color: Colors.grey)),
                    Text('Today', style: TextStyle(color: Colors.red)),
                    Text('16° Partly Cloudy'),
                  ],
                ),
                Column(
                  children: [
                    Text('Fri Aug 09', style: TextStyle(color: Colors.grey)),
                    Text('8° Rainy'),
                  ],
                ),
                Column(
                  children: [
                    Text('Sat Aug 10', style: TextStyle(color: Colors.grey)),
                    Text('18° Sunny'),
                  ],
                ),
              ],
            ),
          ),
          
          // Avatar and Outfit Controls
          Expanded(
            child: Center(
              child: Column(
                children: [
                  // Your Avatar
                  Expanded(
                    child: Image.asset('assets/avatar.jpg'), // Replace with actual avatar widget
                  ),

                  // Outfit Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          // Previous Outfit
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Generate Outfit
                        },
                        child: const Text('Generate Outfit'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          // Next Outfit
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu), // Drawer icon
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WardrobePage()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation Bar
          BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'posting.dart';
// import 'bottomnav.dart';
// import 'wardrobe.dart'; // Import the wardrobe page
// import 'package:model_viewer_plus/model_viewer_plus.dart'; // Import the model viewer package

// class AvatarPage extends StatefulWidget {
//   const AvatarPage({super.key});

//   @override
//   _AvatarPageState createState() => _AvatarPageState();
// }

// class _AvatarPageState extends State<AvatarPage> {
//   File? _imageFile;
//   final ImagePicker _picker = ImagePicker();
//   int _currentIndex = 2; // Current index for "Wardrobe" screen

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

//   void _onNavBarTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFFFDF5),
//         automaticallyImplyLeading: false,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/logo1.png',
//               height: 80,
//               width: 80,
//               fit: BoxFit.contain,
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.camera_alt),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const Posting()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Weather Info Row
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   children: [
//                     Text('Thu Aug 08', style: TextStyle(color: Colors.grey)),
//                     Text('Today', style: TextStyle(color: Colors.red)),
//                     Text('16° Partly Cloudy'),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Text('Fri Aug 09', style: TextStyle(color: Colors.grey)),
//                     Text('8° Rainy'),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Text('Sat Aug 10', style: TextStyle(color: Colors.grey)),
//                     Text('18° Sunny'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
          
//           // Avatar and Outfit Controls
//           Expanded(
//             child: Center(
//               child: Column(
//                 children: [
//                   // 3D Model Viewer instead of Avatar Image
//                   Expanded(
//                     child: ModelViewer(
//                       src: 'assets/Male.OBJ', // Path to your 3D model
//                       alt: "A 3D model",
//                       autoPlay: true,
//                       autoRotate: false,
//                       cameraControls: true,
//                     ),
//                   ),

//                   // Outfit Controls
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.arrow_back),
//                         onPressed: () {
//                           // Previous Outfit
//                         },
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           // Generate Outfit
//                         },
//                         child: const Text('Generate Outfit'),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.arrow_forward),
//                         onPressed: () {
//                           // Next Outfit
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.menu), // Drawer icon
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const WardrobePage()),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           // Bottom Navigation Bar
//           BottomNavBar(
//             currentIndex: _currentIndex,
//             onTap: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
