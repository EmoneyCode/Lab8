import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RandomUserTab extends StatefulWidget {
  const RandomUserTab({super.key});

  @override
  State<RandomUserTab> createState() => _RandomUserTabState();
}

class _RandomUserTabState extends State<RandomUserTab> {
  final TextEditingController _countController = TextEditingController();
  Future<List<dynamic>>? _futureUsers;

  Future<List<dynamic>> fetchRandomUsers(int count) async {
    final response =
        await http.get(Uri.parse('https://randomuser.me/api/?results=$count'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['results'];
    } else {
      throw Exception('Failed to load users');
    }
  }

  void _fetchData() {
    final input = int.tryParse(_countController.text);
    if (input != null && input > 0) {
      setState(() {
        _futureUsers = fetchRandomUsers(input);
      });
    }
  }

  void _clearData() {
    setState(() {
      _futureUsers = null;
      _countController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random User API'),
        actions: [
          IconButton(onPressed: _fetchData, icon: const Icon(Icons.download)),
          IconButton(onPressed: _clearData, icon: const Icon(Icons.clear)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _countController,
              decoration: const InputDecoration(
                labelText: 'Number of users to fetch',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _futureUsers == null
                  ? const Center(child: Text('Enter a number and tap Fetch'))
                  : FutureBuilder<List<dynamic>>(
                      future: _futureUsers,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('No users found.'));
                        } else {
                          final users = snapshot.data!;
                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final name =
                                  '${user['name']['first']} ${user['name']['last']}';
                              final email = user['email'];
                              final gender = user['gender'];
                              final country = user['location']['country'];
                              final picture = user['picture']['thumbnail'];

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(picture),
                                ),
                                title: Text(name),
                                subtitle: Text(
                                    'Email: $email\nGender: $gender\nCountry: $country'),
                              );
                            },
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}