import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lab8_eat_kks/spotify/apibase.dart';
import 'KKS_Screen/random_user_tab.dart';

Future<void> main() async {
  // Load the .env file before the app starts
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  // List of tabs
  static const List<Widget> tabs = <Widget>[
    RandomUserTab(),
    Apibase(),
  ];

  void _onTappedTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: tabs[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle),
              label: "Random User",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.headphones),
              label: "Spotify",
            ),
          ],
          onTap: _onTappedTab,
        ),
      ),
    );
  }
}
