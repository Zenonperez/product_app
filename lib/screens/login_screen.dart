import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:productes_app/authentification/auth.dart';
import 'package:productes_app/providers/login_form_provider.dart';
import 'package:productes_app/screens/register_screen.dart';
import 'package:productes_app/ui/input_decorations.dart';
import 'package:productes_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

//Screen la cual se emplea el login para entrar en la funcionalidad principal de la aplicación que permite modificar y visualizar y añadir los productos.
//Para que un usuario se conecte tendra que rellenar los campos el cual corresponden a su usario y pulsar el boton iniciar sesión.
//Si el usuario no dispone de una cuenta tendra que pulsar el texto crear una cuenta que consiste en un boton, ese texto le llevara a la regsiter screen.
//En caso de error al iniciar sesion se mostrara por pantalla.

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Scaffold de login
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 250),
              CardContainer(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text('Login', style: Theme.of(context).textTheme.headline4),
                    SizedBox(height: 30),
                    ChangeNotifierProvider(
                      create: (_) => LoginFormProvider(),
                      child: _LoginForm(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              //Texto boton de registrar a un usuario.
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: RegisterScreen(),
                          type: PageTransitionType.rightToLeft));
                },
                child: Text('Crear una cuenta nueva',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

//Clase del form, esta clase gestiona el formulario de logeo y es la responsable de que un usuario pueda conectarse
class _LoginForm extends StatelessWidget {
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);

    //El formulario utiliza una key correspondiente, cada formulario tendra la suya para poder crear o iniciar sesion la cuenta de un usuario
    return Container(
      child: Form(
        key: loginForm.formKey,
        //TODO: Mantenir la referencia a la Key
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: 'john.doe@gmail.com',
                labelText: 'Correu electrònic',
                prefixIcon: Icons.alternate_email_outlined,
              ),
              onChanged: (value) => loginForm.email = value,
              //Valida que el correo se tenga el formarto de un correo 'letra@letra.letra
              //Si se trara de un correo dejara ponerlo y el usuario debera de poner un correo para que le deje realizar el formulario
              validator: (value) {
                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp = new RegExp(pattern);
                return regExp.hasMatch(value!) ? null : 'No es de tipus correu';
              },
            ),
            SizedBox(height: 30),
            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecorations.authInputDecoration(
                hintText: '*****',
                labelText: 'Contrasenya',
                prefixIcon: Icons.lock_outline,
              ),
              onChanged: (value) => loginForm.password = value,
              //Valida que la contraseña contega almenos o más de 6 caracteres de lo contrario no dejara inciar sesión.
              validator: (value) {
                return (value != null && value.length >= 6)
                    ? null
                    : 'La contrasenya ha de ser de 6 caràcters';
              },
            ),
            SizedBox(height: 30),
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.deepPurple,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                //Boton de inicio de sesion que cambiara a esperi si se esta cargando la sesion de un usuario.
                child: Text(
                  loginForm.isLoading ? 'Esperi' : 'Iniciar sesion',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              //Aqui se podrucira el inicio de sesion.
              onPressed: loginForm.isLoading
                  //Si esta cargando no dejara pulsar el boton.
                  ? null
                  //De lo contrario dejara pulsarlo y empezaria el inicio de sesion.
                  : () async {
                      // Deshabilitamos el tecladp
                      FocusScope.of(context).unfocus();
                      //Si el formulario es valido
                      if (loginForm.isValidForm()) {
                        //Primero estara cargando
                        loginForm.isLoading = true;
                        //Luego intentara inciar sesion y de conseguirlo cargara a la pantalla home.
                        try {
                          await Auth().singInWithEmailAndPassword(
                              loginForm.email, loginForm.password);
                          await Future.delayed(Duration(seconds: 2));
                          Navigator.pushReplacementNamed(context, 'home');
                          //De fallara capturara las posibles excepciones que puedan surgir por inciar la sesion.
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'invalid-credential') {
                            _error =
                                'Error: Los datos aportados son erroneos, es posible que no exista el usuario o la contraseña este mal';
                          } else {
                            _error = 'Error al iniciar sesion: ${e.message}';
                          }
                          //Mostrara las excepciones por pantalla.
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(_error),
                          duration: Duration(seconds: 5),
                        ));
                      }
                      //Dejara de cargar.
                      loginForm.isLoading = false;
                    },
            ),
          ],
        ),
      ),
    );
  }
}
