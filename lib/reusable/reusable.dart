import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {

  final String hintText;
  final IconData icon;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  const CustomTextField({
    this.onSuffixTap,
    this.suffixIcon,
    required this.hintText,
    required this.icon,
    this.obscureText = false,


    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white), // Text the user types
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2B2B2B), // Dark input background
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Color(0xFFFF7A19)),
        suffixIcon: suffixIcon != null
            ? IconButton(
          icon: Icon(
            suffixIcon,
            color: Colors.white54,
          ),
          onPressed: onSuffixTap,
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.transparent), // Clean look
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFF7A19)), // Orange glow when clicking
        ),
      ),
    );
  }
}
