import 'package:flutter/material.dart';
import 'package:movie_explorer/authentication/login.dart';


void main(){
  runApp(const  myApp());

}
class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LoginScreen.id,
      routes:{
        LoginScreen.id: (context) => LoginScreen(),
      }

    );

  }
}
