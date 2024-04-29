import 'package:flutter/material.dart';
import 'package:productes_app/models/models.dart';

//Provider que verificara que un producto este rellenado correctamente a la hora de meter uno nuevo o de modificar uno existente actualizandolo.
class ProductFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  Product tempProduct;

  ProductFormProvider(this.tempProduct);

  bool isValidForm() {
    print(tempProduct.name);
    print(tempProduct.price);
    print(tempProduct.available);
    return formKey.currentState?.validate() ?? false;
  }

  updateAvaliability(bool value) {
    print(value);
    this.tempProduct.available = value;
    notifyListeners();
  }
}
