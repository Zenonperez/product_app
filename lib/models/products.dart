import 'dart:convert';

//Clase que se utilizara de modelo a la hora de crea un producto o cambiar el valor a uno existente
class Product {
  //Variables que tiene el producto.
  bool available;
  String name;
  String? picture;
  double price;

  String? id;
  //Constructor del producto
  Product(
      {required this.available,
      required this.name,
      this.picture,
      required this.price,
      this.id});

  //Metodos para mapear y transformar el producto en json o conseguirlo de uno existente.
  factory Product.fromJson(String str) => Product.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        available: json["available"],
        name: json["name"],
        picture: json["picture"],
        price: json["price"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "available": available,
        "name": name,
        "picture": picture,
        "price": price,
      };

  //Metodo para crear una copia del producto
  Product copy() => Product(
      available: this.available,
      name: this.name,
      price: this.price,
      picture: this.picture,
      id: this.id);
}
