import 'package:flutter/material.dart';
import 'clothingitem.dart';

class ClothingManager extends ChangeNotifier {
  final List<ClothingItem> _clothingItems = [];

  // Get a list of all clothing items.
  List<ClothingItem> get clothingItems => _clothingItems;

  // Add a new clothing item and notify listeners to update the UI.
  void addClothingItem(ClothingItem item) {
    _clothingItems.add(item);
    notifyListeners();
  }

  // Remove a clothing item.
  void removeClothingItem(ClothingItem item) {
    _clothingItems.remove(item);
    notifyListeners();
  }

  // Update the anchor point of a clothing item.
  void updateClothingAnchorPoint(ClothingItem item, Offset newAnchorPoint) {
    item.updateAnchorPoint(newAnchorPoint);
    notifyListeners(); // Notify the UI of changes.
  }

  // Increase the scale of a clothing item.
  void increaseScale(ClothingItem item) {
    item.updateScale(item.scale + 0.03); // Increase scale by 0.1 (adjust as needed).
    notifyListeners();
  }

  // Decrease the scale of a clothing item.
  void decreaseScale(ClothingItem item) {
    item.updateScale(item.scale - 0.03); // Decrease scale by 0.1 (adjust as needed).
    notifyListeners();
  }

  // Increase the rotation of a clothing item.
  void increaseRotation(ClothingItem item) {
    item.updateRotation(item.rotation + 2.5); // Rotate by 10 degrees (adjust as needed).
    notifyListeners();
  }

  // Decrease the rotation of a clothing item.
  void decreaseRotation(ClothingItem item) {
    item.updateRotation(item.rotation - 2.5); // Rotate by 10 degrees (adjust as needed).
    notifyListeners();
  }

  // Clear all clothing items.
  void clearAll() {
    _clothingItems.clear();
    notifyListeners();
  }
}
