import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBService {

  static const apiKey = "8a34fcfb84d88f195c129dfd04b1ea07";

  static Future<List> searchMovies(String query) async {

    final url = Uri.parse(
        "https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query");

    final response = await http.get(url);

    if (response.statusCode == 200) {

      final data = json.decode(response.body);

      return data["results"];

    } else {
      throw Exception("Failed to load movies");
    }
  }
}