import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:productes_app/authentification/auth.dart';
import 'package:productes_app/providers/login_form_provider.dart';
import 'package:productes_app/screens/register_screen.dart';
import 'package:productes_app/ui/input_decorations.dart';
import 'package:productes_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

 bool isitLogin = true;

class LoginScreen extends StatefulWidget {  
 
 @override
 State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen>{

  bool _isitLogin = isitLogin;
  String loginRegister = 'Login';
  String textoBoton = 'Crear una cuenta nueva';
 
 
  @override
  Widget build(BuildContext context) {

    
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
                    Text( loginRegister, style: Theme.of(context).textTheme.headline4),
                    SizedBox(height: 30),
                    ChangeNotifierProvider(
                      create: (_) => LoginFormProvider(),
                      child: _LoginForm(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: (){
                
                  Navigator.push(context, PageTransition(child: RegisterScreen(), type: PageTransitionType.rightToLeft) );

                  
                },
                child: Text( textoBoton,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  
  String _error = '';
  
  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    bool StateLogin = isitLogin;

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
                  loginForm.isLoading 
                  ? 'Esperi' 
                  : 'Iniciar sesion',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed:
                loginForm.isLoading
                  ? null
                  : () async {
                      // Deshabilitam el teclat
                      FocusScope.of(context).unfocus();        
                      if (loginForm.isValidForm()) {
                        loginForm.isLoading = true;
                        try{

                          await Auth().singInWithEmailAndPassword(loginForm.email, loginForm.password);
                          await Future.delayed(Duration(seconds: 2));
                          Navigator.pushReplacementNamed(context, 'home');

                          }on FirebaseAuthException catch (e){
                            if (e.code == 'invalid-credential'){
                                _error = 'Error: Los datos aportados son erroneos, es posible que no exista el usuario o la contraseña este mal';
                            }  else {
                              _error = 'Error al iniciar sesion: ${e.message}';
                            }
                          } ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _error), 
                              duration: Duration(
                                seconds: 5),
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
