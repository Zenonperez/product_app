import 'package:flutter/material.dart';

class LoginFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  
  String email = '';
  String password = '';
  String loginRegister = 'Login';
  String buttonText = 'Crear una nueva cuenta';


  bool _isLogin = true;
  bool get isLogin => _isLogin;
  set isLogin(bool value) {
    _isLogin = value;
    notifyListeners();
    if (isLogin){
      loginRegister = 'Login';
      buttonText = 'Crear una nueva cuenta';
    }else{
      loginRegister = 'Registrarse';
      buttonText = 'Iniciar sesion';
    }
    
  }



  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    print('Valor del formulari: ${formKey.currentState?.validate()}');
    print('$email - $password');
    return formKey.currentState?.validate() ?? false;
  }
}
