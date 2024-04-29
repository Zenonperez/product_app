import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:productes_app/models/models.dart';
import 'package:productes_app/screens/loading_screen.dart';
import 'package:productes_app/services/products_service.dart';
import 'package:productes_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

//Screen principal de la aplicación la cual ingresaremos una vez realizado el login de un usuario.
//En esta screen se mostraran los productos que estan con su precio nombre y disponibilidad de este.
//Estos prodcutos se encuentran en una base de datos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsService = Provider.of<ProductsService>(context);

    if (productsService.isLoading) return LoadingScreen();
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo,
        title: Row(children: [
          Text(
            'Productes',
            style: TextStyle(color: Colors.white),
          ),
          Container(width: 120),
          MaterialButton(
              color: Colors.pink,
              child: Text(
                'Desconectarse',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                FirebaseAuth.instance.authStateChanges().listen((User? user) {
                  if (user == null) {
                    Navigator.pushReplacementNamed(context, 'login');
                  } else {
                    Navigator.pushReplacementNamed(context, 'home');
                  }
                });
              }),
        ]),
      ),
      body: ListView.builder(
        itemCount: productsService.products.length,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
          child: ProductCard(
            product: productsService.products[index],
          ),
          onTap: () {
            productsService.newPicture = null;
            productsService.selectedProduct =
                productsService.products[index].copy();
            Navigator.of(context).pushNamed('product');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          productsService.newPicture = null;
          productsService.selectedProduct =
              Product(available: true, name: '', price: 0);
          Navigator.of(context).pushNamed('product');
        },
      ),
    );
  }
}
