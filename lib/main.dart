import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://aomyrjehryeouplkzhwi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvbXlyamVocnllb3VwbGt6aHdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE5MDMwMjcsImV4cCI6MjEwNzQ3OTAyN30.7SOPYu4zurfH2M_sPjB1EMbxDoloE0Jam5hY4FBAxcg',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyrello',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFD4AF37),
          surface: Color(0xFF1A1A1A),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isSwedish = true;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const ChatScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        indicatorColor: const Color(0xFFD4AF37).withOpacity(0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Hem'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Karta'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chatt'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Kalender'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hyrello', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.language, color: Color(0xFFD4AF37)), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Varf\u00f6r Hyrello?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                SizedBox(height: 8),
                Text('Hyra verifierade experter i n\u00e4rheten. Enkelt, s\u00e4kert och transparent.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Tillg\u00e4ngliga experter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ExpertCard(
            name: 'Anna Svensson',
            title: 'Advokat',
            price: '850 kr/tim',
            rating: 4.9,
            description: 'Erfaren jurist med fokus p\u00e5 avtalsr\u00e4tt och fastigheter. Hj\u00e4lper dig snabbt och tydligt.',
            location: 'S\u00f6dermalm',
          ),
          ExpertCard(
            name: 'Erik Lindberg',
            title: 'M\u00e4klare',
            price: '650 kr/tim',
            rating: 4.7,
            description: 'Lokal m\u00e4klare med 10 \u00e5rs erfarenhet. Hj\u00e4lper dig hitta r\u00e4tt bostad.',
            location: '\u00d6stermalm',
          ),
        ],
      ),
    );
  }
}

class ExpertCard extends StatelessWidget {
  final String name, title, price, description, location;
  final double rating;

  const ExpertCard({
    super.key,
    required this.name,
    required this.title,
    required this.price,
    required this.rating,
    required this.description,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(backgroundColor: Color(0xFFD4AF37), child: Icon(Icons.person, color: Colors.black)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(title, style: const TextStyle(color: Color(0xFFD4AF37))),
                    ],
                  ),
                ),
                Text(price, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFD4AF37), size: 16),
                Text(' $rating', style: const TextStyle(fontSize: 13)),
                const Spacer(),
                Text(location, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text('Samtycke', style: TextStyle(color: Color(0xFFD4AF37))),
                      content: const Text('Jag godk\u00e4nner att inte missbruka expertens kontaktuppgifter eller trakassera. Hyrello kan anv\u00e4ndas som bevis vid polisanm\u00e4lan.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Avbryt')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bokning bekr\u00e4ftad! Du v\u00e4gleds nu till kalendern.')),
                            );
                          },
                          child: const Text('Godk\u00e4nn & hyra'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Hyra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Karta', style: TextStyle(color: Color(0xFFD4AF37))), backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 80, color: const Color(0xFFD4AF37).withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Karta kommer h\u00e4r', style: TextStyle(fontSize: 18)),
            const Text('Experter i n\u00e4rheten visas p\u00e5 kartan', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatt', style: TextStyle(color: Color(0xFFD4AF37))), backgroundColor: Colors.transparent),
      body: const Center(child: Text('Dina chattar med experter')),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalender', style: TextStyle(color: Color(0xFFD4AF37))), backgroundColor: Colors.transparent),
      body: const Center(child: Text('Dina bokningar och schema')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil', style: TextStyle(color: Color(0xFFD4AF37))), backgroundColor: Colors.transparent),
      body: const Center(child: Text('Din profil och inst\u00e4llningar')),
    );
  }
}
