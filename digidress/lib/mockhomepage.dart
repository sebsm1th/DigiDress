import 'package:flutter/material.dart';

class MockHomePage extends StatelessWidget {
  const MockHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Mock Home Page')),
    );
  }
}
