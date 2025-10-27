/*
Krystal Schneider
10/29/2025
Reflection: Using finals to fetch API data was still a challenge, especially making that data into
usable data in order to display it. JSON is also still a little confusing compared to most
other langanges and how they handle it.
*/


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Main StatefulWidget that displays Random User data
class RandomUserTab extends StatefulWidget {
  const RandomUserTab({super.key});

  @override
  State<RandomUserTab> createState() => _RandomUserTabState();
}

// State class that holds the UI logic and data for RandomUserTab
class _RandomUserTabState extends State<RandomUserTab> {
  final TextEditingController _countController = TextEditingController();

  Future<List<dynamic>>? _futureUsers;

  // Fetches a list of random users from the public RandomUser API
  Future<List<dynamic>> fetchRandomUsers(int count) async {
    // Perform a GET request to the API with the user-specified count
    final response =
        await http.get(Uri.parse('https://randomuser.me/api/?results=$count'));

    // If successful decode the response body as JSON
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['results'];
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Called when the user taps the "Fetch" icon
  // Validates input and triggers the API call
  void _fetchData() {
    final input = int.tryParse(_countController.text);

    // Only proceed if input is a positive number
    if (input != null && input > 0) {
      setState(() {
        _futureUsers = fetchRandomUsers(input);
      });
    }
  }

  // Clears both the fetched data and input field
  void _clearData() {
    setState(() {
      _futureUsers = null; // Reset the Future
      _countController.clear(); // Clear the text input
    });
  }

  // Main build widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random User API'),
        actions: [
          // Button to trigger user fetch
          IconButton(onPressed: _fetchData, icon: const Icon(Icons.download)),
          // Button to clear fetched data
          IconButton(onPressed: _clearData, icon: const Icon(Icons.clear)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Input field for the number of users to fetch
            TextField(
              controller: _countController,
              decoration: const InputDecoration(
                labelText: 'Number of users to fetch',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number, // Numeric input only
            ),
            const SizedBox(height: 12),

            // The main content area — displays either instructions, loading, error, or results
            Expanded(
              child: _futureUsers == null
                  // Initial message before any fetch
                  ? const Center(child: Text('Enter a number and tap Fetch'))

                  : FutureBuilder<List<dynamic>>(
                      future: _futureUsers,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());

                        // Show error message if the fetch failed
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));

                        // Show message if no data is returned
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('No users found.'));

                        // If successful, display the user list
                        } else {
                          final users = snapshot.data!;

                          // List of user titles
                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];

                              // JSON extraction
                              final name =
                                  '${user['name']['first']} ${user['name']['last']}';
                              final email = user['email'];
                              final gender = user['gender'];
                              final country = user['location']['country'];
                              final picture = user['picture']['thumbnail'];

                              // Each user is displayed as a ListTile with avatar and details
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(picture),
                                ),
                                title: Text(name),
                                subtitle: Text(
                                  'Email: $email\nGender: $gender\nCountry: $country',
                                ),
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
