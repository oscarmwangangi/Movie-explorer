import 'package:flutter/material.dart';
import 'package:movie_explorer/authentication/login.dart';
import 'package:movie_explorer/appUI/favorites/favorites.dart';
import 'package:movie_explorer/appUI/home/home.dart';
import 'package:movie_explorer/appUI/search/search.dart';
import 'package:movie_explorer/appUI/favorites/favorites.dart';

void main(){
  runApp(const  myApp());

}
class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: LoginScreen.id,
      routes:{
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) =>HomeScreen(),
        FavoritesScreen.id: (context) =>FavoritesScreen(),
        SearchScreen.id: (context) =>SearchScreen(),
      }

    );

  }
}
