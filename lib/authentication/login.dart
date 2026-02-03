import 'package:flutter/material.dart';
import 'package:movie_explorer/reusable/reusable.dart';

import '../appUI/home/home.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body:Container(

        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/view-urban-dark-city-with-fog.jpg'),
            fit: BoxFit.cover
          )
        ),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // icons, text

              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/cinema_film_movie_multimedia_player_icon.png'),
                    fit: BoxFit.contain, // Contain usually works better for icons to avoid cropping
                  ),
                ),
              ),

              const SizedBox(height: 15), // Gives the text some breathing room

              // The App Name
              const Text(
                'MOVIE EXPLORER',
                style: TextStyle(
                  color: Colors.amber, // Your signature orange
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5, // Gives it that cinematic "Poster" look
                  fontFamily: 'sans-serif-condensed', // Or a custom Google Font like 'Bebas Neue'
                ),
              ),
              // text fields
              // Username / Email Field
              Container(
                margin: const EdgeInsets.only(bottom: 20), // Spacing between fields
                child: CustomTextField(
                  hintText: "User Name",
                  icon:  Icons.person,

                ),
              ),

// Password Field
              Container(
                child: CustomTextField(
                  hintText: "Password",
                  icon: Icons.lock,

                  suffixIcon:
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  obscureText: obscureText,
                  onSuffixTap: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                )
              ),
                  // button
              // 1. The Gradient Login Button
              Container(
                margin: const EdgeInsets.only( top:20),
                width: double.infinity, // Makes the button full-width
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC63725), Color(0xFFFF7A19)], // Using your hex codes
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => const HomeScreen()
                    )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 20),

    // 2. The Bottom Links (Forgot Password & Sign Up)
    // Use a Row to hold multiple text widgets horizontally
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color(0xFFFF7A19), decoration: TextDecoration.underline),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

            ],
          )

        )
      ),

    );
  }
}

