import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:productes_app/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:productes_app/models/products.dart';

class ProductsService extends ChangeNotifier{

  final String _baseUrl = 'flutter-app-productos-21bac-default-rtdb.europe-west1.firebasedatabase.app';

  final List<Product> products = [];
  late Product selectedProduct;
  File? newPicture;

  bool isLoading = true;
  bool isSaving = false;

  ProductsService(){
    this.loadProducts();

  }

  Future loadProducts() async{
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

  Future saveOrCreateProduct(Product product) async{
    isSaving = true;
    notifyListeners();

    if(product.id == null){
      createProduct(product);
    }else{
      await updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final resp = await http.put(url, body: product.toJson());
    final decodeData = resp.body;
    print(decodeData);

    final index = this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;

    return product.id!;
    }

    Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.post(url, body: product.toJson());
    final decodeData = json.decode(resp.body);
    product.id = decodeData['name'];
    this.products.add(product);
    notifyListeners();


    return product.id!;
    }

    void updateSelectedImage(String path){
      this.newPicture = File.fromUri(Uri(path: path));

      this.selectedProduct.picture = path;
      notifyListeners();
    }

    Future<String?> uploadImage() async{
      if (this.newPicture == null) return null;

      this.isSaving = true;
      notifyListeners();

      final url = Uri.parse('https://api.cloudinary.com/v1_1/dotg2moxz/image/upload?upload_preset=preset');

      final imageUploadRequest = http.MultipartRequest('POST', url);

      final file = await http.MultipartFile.fromPath('file', newPicture!.path);

      imageUploadRequest.files.add(file);

      final streamResponse = await imageUploadRequest.send();

      final resp = await http.Response.fromStream(streamResponse);

      if (resp.statusCode != 200 && resp.statusCode != 201){
        print('Se ha producido un error');
        print(resp.body);
        return null;
      }

      this.newPicture = null;
      final decodeData = json.decode(resp.body);
      return decodeData ['secure_url'];
    }
}