
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'), 
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
      ),
        body: Center(
          child: CircularProgressIndicator(),
          ),
    );
  }
}