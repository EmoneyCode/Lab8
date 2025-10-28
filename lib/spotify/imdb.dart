import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lab8_eat_kks/spotify/movie.dart';

/*
Ethan Trammell
Lab 8
This lab is being used to learn about apis and specifically the use of json decoding
methods
This is my api tabbed page of imdb. 
 */
class IMDb extends StatefulWidget {
  const IMDb({super.key});
  @override
  State<StatefulWidget> createState() {
    return _IMDbstate();
  }
}

class _IMDbstate extends State<IMDb> {
  late final String bearerToken;

  final TextEditingController _controller = TextEditingController();
  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Read the token from .env
    bearerToken = dotenv.env['TMDB_BEARER_TOKEN'] ?? '';
  }

  //fetches the movie data
  Future<void> fetch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final url = Uri.parse(
      //this is what is being searched
      'https://api.themoviedb.org/3/search/movie?query=$query',
    );
    //api key
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $bearerToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = (data['results'] as List)
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList();
      setState(() {
        _movies = results;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Error: ${response.statusCode}';
        _isLoading = false;
      });
    }
  }

  //clears data
  void _clearData() {
    setState(() {
      _movies.clear();
      _controller.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IMDb'),
        actions: [
          IconButton(onPressed: fetch, icon: Icon(Icons.search)),
          IconButton(onPressed: _clearData, icon: Icon(Icons.clear)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter a movie',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.0),
            //this is all of the statements that is can go throught during and after fetching
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              )
            else if (_movies.isEmpty)
              Center(child: Text('Movies are Empty'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _movies.length,
                  itemBuilder: (context, index) {
                    final movie = _movies[index];
                    return ListTile(
                      title: Text(movie.title),
                      subtitle: Text('Release Date: ${movie.releaseDate}'),
                      trailing: Text('${movie.voteAverage}⭐'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
