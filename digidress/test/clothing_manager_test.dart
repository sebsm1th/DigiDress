import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:digidress/clothingitem.dart'; // Adjust the import according to your project structure
import 'package:digidress/clothingmanager.dart';

class MockClothingItem extends ClothingItem {
  MockClothingItem(String documentId, String imageUrl, ClothingType type)
      : super(documentId: documentId, imageUrl: imageUrl, type: type);
}


void main() {
  group('ClothingManager Tests', () {
    late ClothingManager clothingManager;

    setUp(() {
      clothingManager = ClothingManager();
    });

    test('Add clothing item', () {
      final item = MockClothingItem(
        'id1',
        'https://example.com/image1.jpg',
        ClothingType.top, // Pass a ClothingType enum value
      );
      clothingManager.addClothingItem(item);
      expect(clothingManager.clothingItems, contains(item));
    });

    test('Update anchor point', () {
      final item = MockClothingItem('id1',
        'https://example.com/image1.jpg',
        ClothingType.top,);
      clothingManager.addClothingItem(item);
      final newAnchorPoint = Offset(10.0, 20.0);

      clothingManager.updateClothingAnchorPoint(item, newAnchorPoint);

      expect(item.anchorPoint, newAnchorPoint); // Make sure to have anchorPoint property in your ClothingItem
    });

    test('Increase scale', () {
      final item = MockClothingItem('id1',
        'https://example.com/image1.jpg',
        ClothingType.top,);
      clothingManager.addClothingItem(item);
      final initialScale = item.scale;

      clothingManager.increaseScale(item);

      expect(item.scale, initialScale + 0.03);
    });

    test('Decrease scale', () {
      final item = MockClothingItem('id1',
        'https://example.com/image1.jpg',
        ClothingType.top,);
      clothingManager.addClothingItem(item);
      final initialScale = item.scale;

      clothingManager.decreaseScale(item);

      expect(item.scale, initialScale - 0.03);
    });

    test('Increase rotation', () {
      final item = MockClothingItem('id1',
        'https://example.com/image1.jpg',
        ClothingType.top,);
      clothingManager.addClothingItem(item);
      final initialRotation = item.rotation;

      clothingManager.increaseRotation(item);

      expect(item.rotation, initialRotation + 2.5);
    });

    test('Decrease rotation', () {
      final item = MockClothingItem('id1',
        'https://example.com/image1.jpg',
        ClothingType.top,);
      clothingManager.addClothingItem(item);
      final initialRotation = item.rotation;

      clothingManager.decreaseRotation(item);

      expect(item.rotation, initialRotation - 2.5);
    });

    test('Clear all clothing items', () {
      final item1 = MockClothingItem('id1',
        'https://example.com/image1.jpg',
        ClothingType.top,);
      final item2 = MockClothingItem('id1',
        'https://example.com/image1.jpg',
        ClothingType.top,);
      clothingManager.addClothingItem(item1);
      clothingManager.addClothingItem(item2);

      clothingManager.clearAll();

      expect(clothingManager.clothingItems, isEmpty);
    });
  });
}
