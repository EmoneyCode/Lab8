import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Apibase extends StatefulWidget {
  const Apibase({super.key});
  @override
  State<StatefulWidget> createState() {
    return _apiBaseState();
  }
}

class _apiBaseState extends State<Apibase> {
  late final String bearerToken;

  final TextEditingController _controller = TextEditingController();
  List<dynamic> _movies = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Read the token from .env
    bearerToken = dotenv.env['TMDB_BEARER_TOKEN'] ?? '';
  }
  
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
      'https://api.themoviedb.org/3/search/movie?query=$query',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization':
            'Bearer $bearerToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _movies = data['results'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Error: ${response.statusCode}';
        _isLoading = false;
      });
    }
  }

  void _clearData() {
    _movies.clear();
    _controller.clear();
    _error = null;
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter a movie',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10.0),
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
                    final title = movie['title'] ?? 'No Title';
                    final releaseDate = movie['release_date'] ?? 'Unknown';
                    final voteAverage = movie['vote_average']?.toString() ?? '0';
                    return ListTile(
                      title: Text(title),
                      subtitle: Text('Release Date: $releaseDate'),
                      trailing: Text('⭐ $voteAverage'),
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
