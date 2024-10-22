// test/login_page_test.dart

import 'package:digidress/login_page.dart';
import 'package:digidress/mockcreateaccountpage.dart';
import 'package:digidress/mockhomepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'login_page_test.mocks.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
void main() {
  // Ensure Flutter widgets binding is initialized
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginPage Widget Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUserCredential mockUserCredential;
    late MockUser mockUser;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUserCredential = MockUserCredential();
      mockUser = MockUser();
    });

    testWidgets('LoginPage has email and password TextFields and buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Verify the presence of TextFields and Buttons
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('Shows error message when email or password is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Leave email and password empty

      // Tap the login button
      await tester.tap(find.text('Login'));
      await tester.pump(); // Allow the UI to rebuild

      // Verify that an error message is displayed
      expect(find.text('Please enter email and password'), findsOneWidget);
    });

    testWidgets('Shows error message when login fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      // Build the LoginPage widget with the mocked FirebaseAuth
      await tester.pumpWidget(MaterialApp(
        home: LoginPage(auth: mockFirebaseAuth),
      ));

      // Enter invalid email and password
      await tester.enterText(
          find.byKey(const Key('emailField')), 'invalid@example.com');
      await tester.enterText(
          find.byKey(const Key('passwordField')), 'password123');

      // Tap the login button
      await tester.tap(find.text('Login'));
      await tester.pump(); // Allow the UI to rebuild

      // Verify that an error message is displayed
      expect(find.text('No user found for that email.'), findsOneWidget);
    });

    testWidgets('Navigates to HomePage on successful login',
        (WidgetTester tester) async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('12345');

      // Build the LoginPage widget with the mocked FirebaseAuth
      await tester.pumpWidget(MaterialApp(
        home: LoginPage(auth: mockFirebaseAuth),
        routes: {
          '/home': (context) => const MockHomePage(), // Use imported MockHomePage
        },
      ));

      // Act
      await tester.enterText(
          find.byKey(const Key('emailField')), 'valid@example.com');
      await tester.enterText(
          find.byKey(const Key('passwordField')), 'password123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(); // Wait for navigation animation to complete

      // Assert
      expect(find.byType(MockHomePage), findsOneWidget);
    });

    testWidgets(
        'Navigates to CreateAccountPage when Create Account button is pressed',
        (WidgetTester tester) async {
      // Build the LoginPage widget
      await tester.pumpWidget(MaterialApp(
        home: const LoginPage(),
        routes: {
          '/createAccount': (context) =>
              const MockCreateAccountPage(), // Use imported MockCreateAccountPage
        },
      ));

      // Act
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(); // Wait for navigation animation to complete

      // Assert
      expect(find.byType(MockCreateAccountPage), findsOneWidget);
    });
  });
}
