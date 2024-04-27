import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:productes_app/firebase_options.dart';
import 'package:productes_app/screens/product_screen.dart';
import 'package:productes_app/screens/register_screen.dart';
import 'package:productes_app/screens/screens.dart';
import 'package:productes_app/services/services.dart';
import 'package:provider/provider.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 runApp(AppState());
}

class AppState extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [ChangeNotifierProvider(create: ( _ ) => ProductsService(),
    )
    ],
    child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Productes App',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      initialRoute: 'login',
      routes: {
        'login': (_) => LoginScreen(),
        'home': (_) => HomeScreen(),
        'product': (_) => ProductScreen(),
        'register': (_) => RegisterScreen(),
      },
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[300],
      ),
    );
  }
}
