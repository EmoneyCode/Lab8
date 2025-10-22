import 'package:flutter/material.dart';
import 'KKS_Screen/random_user_tab.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _MainAppState();
  }
}

class _MainAppState extends State<MainApp> {
  int _selectedindex = 0;
  static const List<Widget> tabs = <Widget>[
    const RandomUserTab(),
    const Center(),
  ];

  void _onTappedTab(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: tabs[_selectedindex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedindex,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.abc), label: "Random User"),
            BottomNavigationBarItem(icon: Icon(Icons.abc_rounded), label: "Spotify"),
          ],
          onTap: _onTappedTab,
        ),
      ),
    );
  }
}
