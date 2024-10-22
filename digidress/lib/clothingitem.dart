// import 'package:flutter/material.dart';

// // Define the ClothingType enum
// enum ClothingType {
//   top,
//   pants,
//   dress,
//   outerwear,
//   shoes, 
//   accessories,
//   // Add other clothing types as needed
// }

// class ClothingItem {
//   final String imageUrl;
//   Offset anchorPoint; // Position of the clothing item relative to the avatar.
//   double scale; // Scale to resize the clothing item.
//   double rotation; // Rotation angle in degrees.
//   ClothingType type; // Type of clothing.
//   //bool isSelected; // Track if the clothing item is selected.

//   // Static map to hold anchor points for each clothing type
//   static final Map<ClothingType, Offset> _anchorPoints = {
//     ClothingType.top: Offset(90, 122),
//     ClothingType.pants: Offset(90, 250),
//     ClothingType.dress: Offset(90, 122),
//     // Add more anchor points for other clothing types as needed
//   };

//   ClothingItem({
//     required this.imageUrl,
//     this.scale = 1.0,
//     this.rotation = 0.0,
//     required this.type,
//   }) : anchorPoint = _anchorPoints[type] ?? Offset(0, 0);//, isSelected = false; // Set anchor point based on type


//   // Update the anchor point to reposition the clothing item.
//   void updateAnchorPoint(Offset newPoint) {
//     anchorPoint = newPoint;
//   }

//   // Adjust the scale (e.g., for resizing).
//   void updateScale(double newScale) {
//     scale = newScale;
//   }

// //   // Adjust the rotation.
//   void updateRotation(double newRotation) {
//     rotation = newRotation;
//   }

//   // // Method to toggle selection
//   // void toggleSelection() {
//   //   isSelected = !isSelected;
//   // }

//    // Build the widget for the clothing item with position and scale adjustments.
//   Widget buildWidget() {
//     const double fixedWidth = 250; // Set a fixed width for all clothing items.
//     const double fixedHeight = 250; // Set a fixed height for all clothing items.

//     // return GestureDetector(
//     //   onTap: () {
//     //     toggleSelection(); // Toggle selection on tap
//     //   },
//     //   child: Container(
//     //     decoration: BoxDecoration(
//     //       border: isSelected ? Border.all(color: Colors.blue, width: 2) : null, // Indicate selection
//     //     ),
//         return Transform.scale(
//           scale: scale, // Maintain the scale defined in the clothing item.
//           child: Transform.rotate(
//             angle: rotation * 3.14159 / 180, // Convert degrees to radians.
//             child: SizedBox(
//               width: fixedWidth,
//               height: fixedHeight,
//               child: Image.network(
//                 imageUrl,
//                 fit: BoxFit.contain, // Maintain the aspect ratio of the image.
//               ),
//             ),
//           ),
//         );
//       //),
//     //);
//   }
// }

import 'package:flutter/material.dart';

// Define the ClothingType enum
enum ClothingType {
  top,
  pants,
  dress,
  outerwear,
  shoes, 
  accessories,
  // Add other clothing types as needed
}

class ClothingItem {
  final String documentId;
  String imageUrl;
  double scale;
  double rotation;
  ClothingType type;
  Offset anchorPoint;

  //Static map to hold anchor points for each clothing type
  static final Map<ClothingType, Offset> _anchorPoints = {
    ClothingType.top: Offset(90, 122),
    ClothingType.pants: Offset(90, 250),
    ClothingType.dress: Offset(90, 122),
    // Add more anchor points for other clothing types as needed
  };

  ClothingItem({
    required this.documentId,
    required this.imageUrl,
    this.scale = 1.0,
    this.rotation = 0.0,
    required this.type,
    Offset? anchorPoint,
  }) : anchorPoint = anchorPoint ?? _anchorPoints[type] ?? Offset(0, 0);

  // Update the anchor point to reposition the clothing item.
  void updateAnchorPoint(Offset newPoint) {
    anchorPoint = newPoint;
  }

  // Adjust the scale (e.g., for resizing).
  void updateScale(double newScale) {
    scale = newScale;
  }

//   // Adjust the rotation.
  void updateRotation(double newRotation) {
    rotation = newRotation;
  }


  // // Convert ClothingItem to a Map for Firestore.
  // Map<String, dynamic> toMap() {
  //   return {
  //     'imageUrl': imageUrl,
  //     //'scale': scale,
  //     //'rotation': rotation,
  //     'type': type.toString().split('.').last,
  //     //'anchorPointX': anchorPoint.dx,
  //     //'anchorPointY': anchorPoint.dy,
  //   };
  // }

  // Convert ClothingItem to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      // You can choose to store scale and rotation if needed
    };
  }

  // // Create a ClothingItem from Firestore data.
  // static ClothingItem fromMap(String documentId, Map<String, dynamic> data) {
  //   return ClothingItem(
  //     documentId: documentId,
  //     imageUrl: data['imageUrl'],
  //     //scale: data['scale'],
  //     //rotation: data['rotation'],
  //     type: ClothingType.values.firstWhere(
  //         (e) => e.toString().split('.').last == data['type']),
  //     //anchorPoint: Offset(data['anchorPointX'], data['anchorPointY']),
  //   );
  // }

  // Create a ClothingItem from Firestore data with error handling.
  static ClothingItem fromMap(String documentId, Map<String, dynamic> data) {
    String imageUrl = data['imageUrl'] ?? ''; // Default to an empty string if null
    ClothingType type = ClothingType.values.firstWhere(
        (e) => e.toString().split('.').last == (data['type'] ?? ''),
        orElse: () => ClothingType.top); // Default to a specific type

    // You can set default values for scale and rotation if they are not provided
    double scale = data['scale'] is double ? data['scale'] : 1.0;
    double rotation = data['rotation'] is double ? data['rotation'] : 0.0;

    return ClothingItem(
      documentId: documentId,
      imageUrl: imageUrl,
      scale: scale,
      rotation: rotation,
      type: type,
      // Optionally handle anchorPoint if it's present in your data
    );
  }

  //Build the widget for the clothing item with position and scale adjustments.
  Widget buildWidget() {
    const double fixedWidth = 250; // Set a fixed width for all clothing items.
    const double fixedHeight = 250; // Set a fixed height for all clothing items.

    // return GestureDetector(
    //   onTap: () {
    //     toggleSelection(); // Toggle selection on tap
    //   },
    //   child: Container(
    //     decoration: BoxDecoration(
    //       border: isSelected ? Border.all(color: Colors.blue, width: 2) : null, // Indicate selection
    //     ),
        return Transform.scale(
          scale: scale, // Maintain the scale defined in the clothing item.
          child: Transform.rotate(
            angle: rotation * 3.14159 / 180, // Convert degrees to radians.
            child: SizedBox(
              width: fixedWidth,
              height: fixedHeight,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain, // Maintain the aspect ratio of the image.
              ),
            ),
          ),
        );
      //),
    //);
  }
}

