import 'package:firebase_auth/firebase_auth.dart';

//Clase que controlara los metodos a la hora de autentificar el login o register de un usuario.
class Auth {
  //Varaible que se usara para crear la instancia de logeo o registro.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Metodo para registrar un usuario en la base de datos, creando un usuario dentro de esta
  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    final user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  //Metodo que dejara entrar a un usuario al programa si este existe en la base de datos
  Future<void> singInWithEmailAndPassword(String email, String password) async {
    final user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }
}
