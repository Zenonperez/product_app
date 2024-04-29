import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:productes_app/authentification/auth.dart';
import 'package:productes_app/providers/login_form_provider.dart';
import 'package:productes_app/screens/login_screen.dart';
import 'package:productes_app/ui/input_decorations.dart';
import 'package:productes_app/widgets/auth_background_register.dart';
import 'package:productes_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

//Screen similar a la de login pero en vez de inciar sesion sirve para registrar un usuario.
//Esta pantalla crea un usuario en la base de datos para después hacer que pueda iniciar sesion en la aplicación.
//Este usuario al rellenar sus datos lo mandara de vuelta a la login screen para poder iniciar la sesion del usuario creado.
class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackgroundRegister(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 250),
              CardContainer(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text('Register',
                        style: Theme.of(context).textTheme.headline4),
                    SizedBox(height: 30),
                    ChangeNotifierProvider(
                      create: (_) => LoginFormProvider(),
                      child: _RegisterForm(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                //Si se pulsa este texto boton te mandara de vuelta a la login screen para que incies la sesion de un usuario.
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: LoginScreen(),
                          type: PageTransitionType.leftToRight));
                },
                child: Text('Iniciar sesion con una cuenta existente',
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

//Clase que validara el registro usando el provider de loginForm debido a que es similar solo que en vez de logearlo realizara un register pero utilizan lo mismo.
class _RegisterForm extends StatelessWidget {
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Container(
      child: Form(
        key: loginForm.formKey,
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
              //Verificara que el este campo se trate un correo electronico para poder ealizar el formulario
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
              //Verificara que este campo no sea menor a 6 caracteres, si fuese menor no dejaria realizara el fomrulario.
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
                child: Text(
                  loginForm.isLoading ? 'Esperi' : 'Crear cuenta',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed:
                  //Boton que al pulsarlo registrara la cuenta siempre que este correctamente escrita bien en el formulario
                  //Al acabar nos enviara a la pagina de login para pdoer iniciar sesion.
                  loginForm.isLoading
                      //Si esta cargando no dejara pulsar el boton
                      ? null
                      //De lo contrario si que dejara pulsarlo y nos dejara inciar sesion.
                      : () async {
                          // Deshabilitam el teclat
                          FocusScope.of(context).unfocus();
                          if (loginForm.isValidForm()) {
                            loginForm.isLoading = true;
                            try {
                              await Auth().registerWithEmailAndPassword(
                                  loginForm.email, loginForm.password);
                              await Future.delayed(Duration(seconds: 2));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content:
                                    Text('Cuenta registrada correctamente'),
                                duration: Duration(seconds: 5),
                              ));
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: LoginScreen(),
                                      type: PageTransitionType.leftToRight));
                              //Se capturaran las excepciones en el memento que haya un error en el registro.
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'email-already-in-use') {
                                _error =
                                    'Error este mail ya esta en uso y registrado';
                              } else {
                                _error = 'Error de registro: ${e.message}';
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(_error),
                              duration: Duration(seconds: 5),
                            ));
                          }

                          loginForm.isLoading = false;
                        },
            ),
          ],
        ),
      ),
    );
  }
}
