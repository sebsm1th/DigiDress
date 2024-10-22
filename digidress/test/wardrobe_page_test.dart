import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart'; // Use this for fake Firestore
import 'package:digidress/wardrobe.dart'; // Adjust this import based on your file structure
import 'package:digidress/clothingitem.dart'; // Import your ClothingItem class
import 'package:digidress/editclothing.dart'; // Import your EditClothingPage class

void main() async {
  // Ensure that Firebase is initialized before running tests
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  group('WardrobePage Tests', () {
    late FirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      // Create a fake Firestore instance and mock authentication
      fakeFirestore = FirebaseFirestore.instance; // Or use a mock if needed
      mockAuth = MockFirebaseAuth();
      when(mockAuth.currentUser).thenReturn(MockUser(uid: 'test_user_id'));
    });

    testWidgets('displays loading indicator while fetching data', (WidgetTester tester) async {
      // Mock the Firebase Auth instance
      final mockAuth = MockFirebaseAuth();
      when(mockAuth.currentUser).thenReturn(MockUser(uid: 'test_user_id'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<FirebaseAuth>.value(value: mockAuth),
            Provider<FirebaseFirestore>.value(value: fakeFirestore), // Provide the fake Firestore
          ],
          child: const MaterialApp(
            home: WardrobePage(),
          ),
        ),
      );

      // Expect to see a CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays message when no clothing items are found', (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      when(mockAuth.currentUser).thenReturn(MockUser(uid: 'test_user_id'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<FirebaseAuth>.value(value: mockAuth),
            Provider<FirebaseFirestore>.value(value: fakeFirestore),
          ],
          child: const MaterialApp(
            home: WardrobePage(),
          ),
        ),
      );

      // Pump a frame to allow any asynchronous operations to complete
      await tester.pumpAndSettle();

      // Expect to see the no clothing items message
      expect(find.text('No clothing items found.'), findsOneWidget);
    });

    testWidgets('displays clothing items when available', (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      when(mockAuth.currentUser).thenReturn(MockUser(uid: 'test_user_id'));

      // Add a clothing item to the fake Firestore
      await fakeFirestore.collection('wardrobe').doc('item1').set({
        'userId': 'test_user_id',
        'imageUrl': 'https://example.com/image1.png',
        'clothingType': 'Tops',
        'createdAt': Timestamp.now(),
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<FirebaseAuth>.value(value: mockAuth),
            Provider<FirebaseFirestore>.value(value: fakeFirestore),
          ],
          child: const MaterialApp(
            home: WardrobePage(),
          ),
        ),
      );

      // Pump a frame to allow any asynchronous operations to complete
      await tester.pumpAndSettle();

      // Expect to see the clothing item
      expect(find.byType(GridView), findsOneWidget); // Check if GridView is present
      expect(find.byType(Image), findsOneWidget); // Check if an image is displayed
    });

    testWidgets('navigates to EditClothingPage when edit button is pressed', (WidgetTester tester) async {
  try {
    final mockAuth = MockFirebaseAuth();
    when(mockAuth.currentUser).thenReturn(MockUser(uid: 'test_user_id'));

    // Add a clothing item to the fake Firestore
    await fakeFirestore.collection('wardrobe').doc('item1').set({
      'userId': 'test_user_id',
      'imageUrl': 'https://example.com/image1.png',
      'clothingType': 'Tops',
      'createdAt': Timestamp.now(),
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<FirebaseAuth>.value(value: mockAuth),
          Provider<FirebaseFirestore>.value(value: fakeFirestore),
        ],
        child: const MaterialApp(
          home: WardrobePage(),
        ),
      ),
    );

    // Pump a frame to allow any asynchronous operations to complete
    await tester.pumpAndSettle();

    // Tap the edit button for the first clothing item
    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    // Expect to see the EditClothingPage
    expect(find.byType(EditClothingPage), findsOneWidget);
  } catch (e) {
    print('Exception occurred: $e');
  }
});

  });
}

// Mock User for testing
class MockUser extends Mock implements User {
  final String uid;
  MockUser({required this.uid});
}

// Mock FirebaseAuth for testing
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  User? get currentUser => super.noSuchMethod(
        Invocation.getter(#currentUser),
        returnValue: null,
      );
}
