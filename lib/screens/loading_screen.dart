import 'package:flutter/material.dart';

//Screen que se utilizara en el momento que la aplicación este cargando la home scrren en el momento de realizar un login.
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
