import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/algorithms_screen.dart';
import 'screens/performance_screen.dart';
import 'screens/documentation_screen.dart';

void main() {
  runApp(const AlgoMateWebDemoApp());
}

class AlgoMateWebDemoApp extends StatelessWidget {
  const AlgoMateWebDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlgoMate Web Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AlgorithmsScreen(),
    const PerformanceScreen(),
    const DocumentationScreen(),
  ];

  final List<String> _titles = [
    'AlgoMate Web Demo',
    'Algorithm Gallery',
    'Performance Analysis',
    'Documentation',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue[700],
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.apps),
                label: Text('Algorithms'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.speed),
                label: Text('Performance'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book),
                label: Text('Docs'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About AlgoMate Web Demo'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AlgoMate v0.1.6'),
            SizedBox(height: 8),
            Text(
                'Intelligent algorithm selection library with full Flutter Web support',),
            SizedBox(height: 8),
            Text('Platform: Flutter Web'),
            Text('Compatibility: Chrome, Firefox, Safari, Edge'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
