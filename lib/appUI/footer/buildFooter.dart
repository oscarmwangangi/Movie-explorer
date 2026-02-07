import 'package:flutter/material.dart';
import 'package:movie_explorer/appUI/search/search.dart';
import 'package:movie_explorer/appUI/favorites/favorites.dart';
import 'package:movie_explorer/appUI/home/home.dart';

Widget buildFooter(BuildContext context){
  return Container(
      height: 75,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),


      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: (){
              Navigator.pushNamed(context, HomeScreen.id);
            },
            child: _footerItem( Icons.home, "Home", true),
          ),
          GestureDetector(
            onTap: (){
              Navigator.pushNamed(context, SearchScreen.id);
            },
            child:  _footerItem( Icons.search, "Search", false),
          ),
          GestureDetector(
            onTap: (){
              Navigator.pushNamed(context, FavoritesScreen.id);
            },
            child:  _footerItem(Icons.favorite_border, "favorite", false),
          )



        ],

      )

  );

}
Widget _footerItem(IconData icon,String lable, bool isActive) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        icon,
          color: isActive ? Colors.white : Colors.grey
      ),
      Text(
        lable,
        style: TextStyle(
            color: isActive ? Colors.white : Colors.grey
        ),
      ),
    ],
  );
}