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

class User {
  final String name;
  final String email;
  final String gender;
  final String country;
  final String picture;

  // Factory constructor to create a User object from a JSON map
  User.fromJson(Map<String, dynamic> json)
      // Extract the full name from nested 'name' map
      : name = '${json['name']['first']} ${json['name']['last']}',
        email = json['email'],
        gender = json['gender'],
        country = json['location']['country'],
        // Extract the thumbnail URL from nested 'picture' map
        picture = json['picture']['thumbnail'];
}

// Main StatefulWidget that displays Random User data
class RandomUserTab extends StatefulWidget {
  const RandomUserTab({super.key});

  @override
  State<RandomUserTab> createState() => _RandomUserTabState();
}

// State class that holds the UI logic and data for RandomUserTab
class _RandomUserTabState extends State<RandomUserTab> {
  final TextEditingController _countController = TextEditingController();

  // Changed to hold a Future of a List of User objects
  Future<List<User>>? _futureUsers;

  // Fetches a list of random users and converts the JSON data into a List<User>
  Future<List<User>> fetchRandomUsers(int count) async {
    // Perform a GET request to the API with the user-specified count
    final response =
        await http.get(Uri.parse('https://randomuser.me/api/?results=$count'));

    // If successful decode the response body as JSON
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Map the list of JSON results to a list of User objects
      return (data['results'] as List).map((u) => User.fromJson(u)).toList();
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

                  // Now using FutureBuilder with Future<List<User>>
                  : FutureBuilder<List<User>>(
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

                          // List of user tiles
                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];

                              // Direct access to User properties
                              final name = user.name;
                              final email = user.email;
                              final gender = user.gender;
                              final country = user.country;
                              final picture = user.picture;

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