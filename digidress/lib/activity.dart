import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Activity Page Content Here'),
      ),
    );
  }
}