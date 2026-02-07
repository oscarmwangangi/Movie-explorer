import 'package:flutter/material.dart';
import 'package:movie_explorer/appUI/footer/buildFooter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String id = "home.dart";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(

            padding: EdgeInsets.only(bottom: 90),


            child: Container(

              child: Text("movie content goes here",
              style: TextStyle(color: Colors.cyan),
              )
            )
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: buildFooter(context),

          )
        ],
      )
    );
  }

  }


