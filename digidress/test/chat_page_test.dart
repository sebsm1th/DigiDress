import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digidress/chat.dart'; // Adjust the import according to your project structure
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Mock class for FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('ChatPage', () {
    testWidgets('displays CircularProgressIndicator when loading', (WidgetTester tester) async {
      // Create a fake Firestore instance
      final fakeFirestore = FakeFirebaseFirestore();
      final mockAuth = MockFirebaseAuth();

      // Provide FirebaseAuth and Firestore mocks to the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<FirebaseAuth>.value(value: mockAuth),
            Provider<FakeFirebaseFirestore>.value(value: fakeFirestore), // Use the fake Firestore here
          ],
          child: const MaterialApp(
            home: ChatPage(),
          ),
        ),
      );

      // Initially, the CircularProgressIndicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Simulate that the loading is finished and friends are fetched
      await tester.pumpAndSettle(); // Let the widget rebuild after async call

      // Now, the CircularProgressIndicator should not be visible
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // Additional tests for friends list and navigation can be added here
  });
}
