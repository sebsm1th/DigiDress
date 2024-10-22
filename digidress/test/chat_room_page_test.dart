import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart'; // For mocking FirebaseAuth
import 'package:digidress/chatroom.dart'; // Adjust the import based on your project structure
import 'package:mockito/mockito.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Create a fake Firestore instance
  final fakeFirestore = FakeFirebaseFirestore();
  final mockAuth = MockFirebaseAuth(); // Create a mock authentication instance
  final mockUser = MockUser(uid: 'test_user_id'); // Create a mock user

  setUp(() {
    // Mock user authentication
    when(mockAuth.currentUser).thenReturn(mockUser);
  });

  testWidgets('ChatRoomPage displays messages', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatRoomPage(
          friendId: 'friend_user_id',
          friendName: 'Friend Name',
          friendProfileImage: 'https://example.com/image.jpg',
        ),
      ),
    );

    // Check if loading indicator is displayed initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Simulate adding a message to the Firestore collection
    await fakeFirestore.collection('chats').doc('test_user_id_friend_user_id').collection('messages').add({
      'content': 'Hello!',
      'senderId': 'test_user_id',
      'type': 'text',
      'timestamp': DateTime.now(), // Directly use DateTime instead of FieldValue
    });

    await tester.pumpAndSettle(); // Wait for the UI to update

    // Check if the message appears on the screen
    expect(find.text('Hello!'), findsOneWidget);
  });
}
