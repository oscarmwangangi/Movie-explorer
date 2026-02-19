import 'package:flutter/material.dart';
import 'package:movie_explorer/appUI/footer/buildFooter.dart';
import 'package:movie_explorer/appUI/widget/movieSection.dart';

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
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [

            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: 90, left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Home",
                        style: TextStyle(color: Colors.white, fontSize: 28,fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 20),
                    Moviesection(title: 'Popular',),
                    Moviesection(title: 'Top Rated'),
                    Moviesection(title: 'Up comming'),
                  ],

                  ),
                )
              ),

            Align(
              alignment: Alignment.bottomCenter,
              child: buildFooter(context),
            )
          ],
        ),
      )
    );
  }

  }


