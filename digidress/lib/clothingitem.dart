// import 'package:flutter/material.dart';

// class ClothingItem {
//   final String imagePath;
//   Offset anchorPoint; // Position of the clothing item relative to the avatar.
//   double scale; // Scale to resize the clothing item.
//   double rotation; // Rotation angle in degrees.

//   ClothingItem({
//     required this.imagePath,
//     required this.anchorPoint,
//     this.scale = 1.0,
//     this.rotation = 0.0,
//   });

//   // Update the anchor point to reposition the clothing item.
//   void updateAnchorPoint(Offset newPoint) {
//     anchorPoint = newPoint;
//   }

//   // Adjust the scale (e.g., for resizing).
//   void updateScale(double newScale) {
//     scale = newScale;
//   }

//   // Adjust the rotation.
//   void updateRotation(double newRotation) {
//     rotation = newRotation;
//   }

//   // Build the widget for the clothing item with position and scale adjustments.
//   Widget buildWidget() {
//     return Positioned(
//       top: anchorPoint.dy,
//       left: anchorPoint.dx,
//       child: Transform.scale(
//         scale: scale, // Maintain the scale defined in the clothing item.
//         child: Transform.rotate(
//           angle: rotation * 3.14159 / 180, // Convert degrees to radians.
//           child: SizedBox(
//             width: 300, // Set your desired width
//             //height: 600, // Set your desired height
//             child: Image.asset(
//               imagePath,
//               fit: BoxFit.contain, // Maintain the aspect ratio of the image
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class ClothingItem {
//   final String imagePath;
//   Offset anchorPoint; // Position of the clothing item relative to the avatar.
//   double scale; // Scale to resize the clothing item.
//   double rotation; // Rotation angle in degrees.

//   ClothingItem({
//     required this.imagePath,
//     required this.anchorPoint,
//     this.scale = 1.0,
//     this.rotation = 0.0,
//   });

//   // Update the anchor point to reposition the clothing item.
//   void updateAnchorPoint(Offset newPoint) {
//     anchorPoint = newPoint;
//   }

//   // Build the widget for the clothing item with position and scale adjustments.
//   Widget buildWidget() {
//     // Fixed dimensions for clothing items
//     const double width = 205;  // Fixed width
//     const double height = 300; // Fixed height

//     return Positioned(
//       top: anchorPoint.dy,
//       left: anchorPoint.dx,
//       child: Transform.scale(
//         scale: scale, // Maintain the scale defined in the clothing item.
//         child: Transform.rotate(
//           angle: rotation * 3.14159 / 180, // Convert degrees to radians.
//           child: SizedBox(
//             width: width,
//             height: height,
//             child: Image.asset(
//               imagePath,
//               fit: BoxFit.contain, // Maintain the aspect ratio of the image
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// // Define the ClothingType enum
// enum ClothingType {
//   shirt,
//   pants,
//   dress,
//   // Add other clothing types as needed
// }

// class ClothingItem {
//   final String imagePath;
//   Offset anchorPoint; // Position of the clothing item relative to the avatar.
//   double scale; // Scale to resize the clothing item.
//   double rotation; // Rotation angle in degrees.
//   final ClothingType type; // Type of clothing.

//   // Static map to hold anchor points for each clothing type
//   static final Map<ClothingType, Offset> _anchorPoints = {
//     ClothingType.shirt: Offset(80, 122), // Example anchor for shirt
//     ClothingType.pants: Offset(180, 400), // Example anchor for pants
//     ClothingType.dress: Offset(85, 140), // Example anchor for dress
//     // Add more anchor points for other clothing types as needed
//   };

//   ClothingItem({
//     required this.imagePath,
//     required this.scale,
//     required this.rotation,
//     required this.type,
//   }) : anchorPoint = _anchorPoints[type] ?? Offset(0, 0); // Set anchor point based on type

//   // Update the anchor point to reposition the clothing item.
//   void updateAnchorPoint(Offset newPoint) {
//     anchorPoint = newPoint;
//   }

//   // Adjust the scale (e.g., for resizing).
//   void updateScale(double newScale) {
//     scale = newScale;
//   }

//   // Adjust the rotation.
//   void updateRotation(double newRotation) {
//     rotation = newRotation;
//   }

//   // Build the widget for the clothing item with position and scale adjustments.
//   Widget buildWidget() {
//     const double fixedWidth = 225; // Set a fixed width for all clothing items.
//     const double fixedHeight = 225; // Set a fixed height for all clothing items.
//     return Positioned(
//       top: anchorPoint.dy,
//       left: anchorPoint.dx,
//       child: Transform.scale(
//         scale: scale, // Maintain the scale defined in the clothing item.
//         child: Transform.rotate(
//           angle: rotation * 3.14159 / 180, // Convert degrees to radians.
//           child: SizedBox(
//             width: fixedWidth,
//             height: fixedHeight,
//             child: Image.asset(
//               imagePath,
//               fit: BoxFit.contain, // Maintain the aspect ratio of the image
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

// Define the ClothingType enum
enum ClothingType {
  shirt,
  pants,
  dress,
  // Add other clothing types as needed
}

class ClothingItem {
  final String imagePath;
  Offset anchorPoint; // Position of the clothing item relative to the avatar.
  double scale; // Scale to resize the clothing item.
  double rotation; // Rotation angle in degrees.
  final ClothingType type; // Type of clothing.
  //bool isSelected; // Track if the clothing item is selected.

  // Static map to hold anchor points for each clothing type
  static final Map<ClothingType, Offset> _anchorPoints = {
    ClothingType.shirt: Offset(90, 122),
    ClothingType.pants: Offset(90, 250),
    ClothingType.dress: Offset(90, 122),
    // Add more anchor points for other clothing types as needed
  };

  ClothingItem({
    required this.imagePath,
    required this.scale,
    required this.rotation,
    required this.type,
  }) : anchorPoint = _anchorPoints[type] ?? Offset(0, 0);//, isSelected = false; // Set anchor point based on type


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

  // // Method to toggle selection
  // void toggleSelection() {
  //   isSelected = !isSelected;
  // }

   // Build the widget for the clothing item with position and scale adjustments.
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
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain, // Maintain the aspect ratio of the image.
              ),
            ),
          ),
        );
      //),
    //);
  }
}