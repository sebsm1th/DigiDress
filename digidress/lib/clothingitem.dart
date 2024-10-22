import 'package:flutter/material.dart';

// Define the ClothingType enum
enum ClothingType {
  top,
  pants,
  dress,
  outerwear,
  shoes,
  accessories,
}

class ClothingItem {
  final String documentId;
  String imageUrl;
  double scale;
  double rotation;
  ClothingType type;
  Offset anchorPoint;

  // Static map to hold default anchor points for each clothing type
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

  // Adjust the rotation.
  void updateRotation(double newRotation) {
    rotation = newRotation;
  }

  // Convert ClothingItem to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'clothingType': type.toString().split('.').last, // Save the string value of the enum
      'scale': scale,
      'rotation': rotation,
      'anchorPointX': anchorPoint.dx,
      'anchorPointY': anchorPoint.dy,
    };
  }

  // Create a ClothingItem from Firestore data with error handling.
  static ClothingItem fromMap(String documentId, Map<String, dynamic> data) {
    String imageUrl = data['imageUrl'] ?? ''; // Default to an empty string if null
    ClothingType type = ClothingType.values.firstWhere(
        (e) => e.toString().split('.').last == (data['clothingType'] ?? ''),
        orElse: () => ClothingType.top); // Default to a specific type if not found

    // Provide default values for scale, rotation, and anchor points
    double scale = data['scale'] is double ? data['scale'] : 1.0;
    double rotation = data['rotation'] is double ? data['rotation'] : 0.0;
    Offset anchorPoint = (data['anchorPointX'] != null && data['anchorPointY'] != null)
        ? Offset(data['anchorPointX'], data['anchorPointY'])
        : _anchorPoints[type] ?? Offset(0, 0);

    return ClothingItem(
      documentId: documentId,
      imageUrl: imageUrl,
      scale: scale,
      rotation: rotation,
      type: type,
      anchorPoint: anchorPoint,
    );
  }

  // Build the widget for the clothing item with position and scale adjustments.
  Widget buildWidget() {
    const double fixedWidth = 250; // Set a fixed width for all clothing items.
    const double fixedHeight = 250; // Set a fixed height for all clothing items.

    return Transform.scale(
      scale: scale, // Apply the scale to the clothing item.
      child: Transform.rotate(
        angle: rotation * 3.14159 / 180, // Convert degrees to radians for rotation.
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
  }
}