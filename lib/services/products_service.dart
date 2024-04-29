import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:productes_app/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:productes_app/models/products.dart';

//Clase que se encarga de los servicios de los prodcutos, esta clase es la responsable de cargar los productos en la aplicacion cogiendolos de la base de datos.
//Es la clase que hace de intermediario entra la aplicacion y la base de datos.
class ProductsService extends ChangeNotifier {
  //Url para acceder a la base de datos
  final String _baseUrl =
      'flutter-app-productos-21bac-default-rtdb.europe-west1.firebasedatabase.app';
  //Lista para guardar los productos
  final List<Product> products = [];
  late Product selectedProduct;
  File? newPicture;

  bool isLoading = true;
  bool isSaving = false;

  ProductsService() {
    this.loadProducts();
  }
  //Metodo que se utiliza para cargar los productos de la base de datos en la aplicacion
  Future loadProducts() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(resp.body);
    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });

    isLoading = false;
    notifyListeners();
  }

  //Metodo que acutaliza la informacion de los productos al modificarlos y los modifica en la base datos desde la aplicacion
  //Este metodo sirve tambien para crear nuevos productos y los añade en la lista de productos
  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    if (product.id == null) {
      createProduct(product);
    } else {
      await updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  //Metodo para actualizar los productos en la base de datos
  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final resp = await http.put(url, body: product.toJson());
    final decodeData = resp.body;
    print(decodeData);

    final index =
        this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;

    return product.id!;
  }

  //Metodo para crear un producto
  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.post(url, body: product.toJson());
    final decodeData = json.decode(resp.body);
    product.id = decodeData['name'];
    this.products.add(product);
    notifyListeners();

    return product.id!;
  }

  //Metodo que actualiza la imagen de un producto al cambiarla
  void updateSelectedImage(String path) {
    this.newPicture = File.fromUri(Uri(path: path));

    this.selectedProduct.picture = path;
    notifyListeners();
  }

  //Metodo que guarda la imagen del producto como su imagen al pulsar guardar haciendo que sea su imagen en la base de datos también.
  Future<String?> uploadImage() async {
    if (this.newPicture == null) return null;

    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dotg2moxz/image/upload?upload_preset=preset');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', newPicture!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();

    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Se ha producido un error');
      print(resp.body);
      return null;
    }

    this.newPicture = null;
    final decodeData = json.decode(resp.body);
    return decodeData['secure_url'];
  }
}
