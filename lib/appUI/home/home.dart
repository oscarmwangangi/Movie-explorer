import 'package:flutter/material.dart';

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
      body: Container(


      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: const Text(
          "© 2026 Movie Explorer",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),

        
        
    ),

    );


  }
}

