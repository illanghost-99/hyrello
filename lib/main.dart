import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch (_) {}
  try {
    await Supabase.initialize(
      url: 'https://aomyrjehryeouplkzhwi.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvbXlyamVocnllb3VwbGt6aHdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE5MDMwMjcsImV4cCI6MjEwNzQ3OTAyN30.7SOPYu4zurfH2M_sPjB1EMbxDoloE0Jam5hY4FBAxcg',
    );
  } catch (_) {}
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
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
        ),
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Hyrello', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
              const SizedBox(height: 8),
              const Text('Hitta eller hyra ut expertis', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 80),
              _bigButton(context, 'Hyra en expert', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen(isExpert: false)))),
              const SizedBox(height: 16),
              _bigButton(context, 'Hyra ut mina tjänster', true, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen(isExpert: true)))),
              const SizedBox(height: 8),
              const Text('149 kr/mån', style: TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bigButton(BuildContext context, String text, bool outlined, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: outlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD4AF37)),
                foregroundColor: const Color(0xFFD4AF37),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onPressed,
              child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onPressed,
              child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final bool isExpert;
  const RegisterScreen({super.key, required this.isExpert});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();

  final _description = TextEditingController();
  final _experience = TextEditingController();
  final _age = TextEditingController();
  final _city = TextEditingController();
  final _price = TextEditingController();

  final List<String> _interests = [];
  final List<String> _availableInterests = ['Juridik', 'Mäklare', 'Frisör', 'Veterinär', 'Läkare', 'Hantverk', 'IT', 'Ekonomi'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainAppScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(widget.isExpert ? 'Registrera dig som expert' : 'Registrera dig', style: const TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / 3, color: const Color(0xFFD4AF37), backgroundColor: Colors.white12),
            const SizedBox(height: 24),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (_step == 0) ..._step1(),
                    if (_step == 1) ..._step2(),
                    if (_step == 2) ..._step3(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                onPressed: _next,
                child: Text(_step == 2 ? 'Klar' : 'Nästa'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _step1() => [
    _field(_email, 'E-post'),
    _field(_password, 'Lösenord', obscure: true),
    _field(_firstName, 'Förnamn'),
    _field(_lastName, 'Efternamn'),
    _field(_phone, 'Telefonnummer'),
  ];

  List<Widget> _step2() {
    if (widget.isExpert) {
      return [
        _field(_description, 'Beskrivning om dig (200-250 tecken)', maxLines: 4),
        _field(_experience, 'Erfarenhet och utbildning'),
        _field(_age, 'Ålder', keyboard: TextInputType.number),
        _field(_city, 'Stad'),
        _field(_price, 'Pris per timme (kr)', keyboard: TextInputType.number),
        const SizedBox(height: 8),
        const Text('Ladda upp foto på dig (person, inte objekt)', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        if (_profileImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_profileImage!, height: 120, width: 120, fit: BoxFit.cover),
          ),
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.camera_alt, color: Color(0xFFD4AF37)),
          label: const Text('Välj foto', style: TextStyle(color: Color(0xFFD4AF37))),
        ),
      ];
    } else {
      return [
        _field(_city, 'Stad'),
        const SizedBox(height: 16),
        const Text('Vilka tjänster är du mest intresserad av?', style: TextStyle(color: Colors.white70)),
      ];
    }
  }

  List<Widget> _step3() {
    if (widget.isExpert) {
      return [
        const Text('Ladda upp certifikat eller betyg', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file, color: Color(0xFFD4AF37)),
          label: const Text('Ladda upp dokument', style: TextStyle(color: Color(0xFFD4AF37))),
        ),
        const SizedBox(height: 24),
        const Text('Din profil skickas för godkännande.', style: TextStyle(color: Colors.white54)),
      ];
    } else {
      return [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableInterests.map((interest) {
            final selected = _interests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: selected,
              selectedColor: const Color(0xFFD4AF37).withOpacity(0.3),
              checkmarkColor: const Color(0xFFD4AF37),
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _interests.add(interest);
                  } else {
                    _interests.remove(interest);
                  }
                });
              },
            );
          }).toList(),
        ),
      ];
    }
  }

  Widget _field(TextEditingController c, String label, {bool obscure = false, int maxLines = 1, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    MapScreen(),
    ListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        indicatorColor: const Color(0xFFD4AF37).withOpacity(0.2),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Hem'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Karta'),
          NavigationDestination(icon: Icon(Icons.list_outlined), label: 'Lista'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
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
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Hyrello', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Experter i närheten', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _expertCard(context, 'Anna Svensson', 'Advokat', '850 kr/tim', 'Erfaren jurist med fokus på avtalsrätt.', 4.9),
          _expertCard(context, 'Erik Lindberg', 'Mäklare', '650 kr/tim', 'Lokal mäklare med 10 års erfarenhet.', 4.7),
          _expertCard(context, 'Sofia Holm', 'Frisör', '450 kr/tim', 'Stylist med fokus på modern hårklippning.', 4.8),
        ],
      ),
    );
  }

  Widget _expertCard(BuildContext context, String name, String title, String price, String desc, double rating) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFFD4AF37), child: Icon(Icons.person, color: Colors.black)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$title · $price\n$desc', style: const TextStyle(color: Colors.white70)),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Color(0xFFD4AF37), size: 16),
            Text(' $rating', style: const TextStyle(color: Colors.white70)),
          ],
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ExpertDetailScreen(name: name, title: title, price: price, desc: desc, rating: rating)));
        },
      ),
    );
  }
}

class ExpertDetailScreen extends StatelessWidget {
  final String name, title, price, desc;
  final double rating;
  const ExpertDetailScreen({super.key, required this.name, required this.title, required this.price, required this.desc, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 40, backgroundColor: Color(0xFFD4AF37), child: Icon(Icons.person, size: 40, color: Colors.black)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(price, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                const Icon(Icons.star, color: Color(0xFFD4AF37), size: 18),
                Text(' $rating', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Text(desc, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            const Text('Recensioner', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('“Mycket professionell och tydlig.” — 5★', style: TextStyle(color: Colors.white70)),
            const Text('“Snabb och trevlig hjälp.” — 4★', style: TextStyle(color: Colors.white70)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text('Samtycke', style: TextStyle(color: Color(0xFFD4AF37))),
                      content: const Text('Jag godkänner att inte missbruka expertens kontaktuppgifter eller trakassera. Hyrello kan användas som bevis vid polisanmälan.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Avbryt')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(name: name)));
                          },
                          child: const Text('Godkänn & skriv'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Skriv till $name'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String name;
  const ChatScreen({super.key, required this.name});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'from': 'expert', 'text': 'Hej! Hur kan jag hjälpa dig?'},
  ];

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'from': 'me', 'text': _controller.text.trim()});
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(widget.name, style: const TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.phone, color: Color(0xFFD4AF37)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final m = _messages[i];
                final isMe = m['from'] == 'me';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFD4AF37) : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(m['text']!, style: TextStyle(color: isMe ? Colors.black : Colors.white)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Skriv ett meddelande...',
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFFD4AF37)), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Karta', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 100, color: const Color(0xFFD4AF37).withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('Live-karta kommer här', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Experter visas som cirklar med foto', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String _filter = 'Alla';
  final List<String> _filters = ['Alla', 'Juridik', 'Mäklare', 'Frisör'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Lista', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _filters.map((f) {
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: selected,
                    selectedColor: const Color(0xFFD4AF37),
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          const Expanded(
            child: Center(child: Text('Filtrerad lista över experter', style: TextStyle(color: Colors.white70))),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tapCount = 0;

  void _onHyrelloTap() {
    setState(() => _tapCount++);
    if (_tapCount >= 7) {
      _tapCount = 0;
      _showPinDialog();
    }
  }

  void _showPinDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Admin', style: TextStyle(color: Color(0xFFD4AF37))),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'PIN'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Avbryt')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
            onPressed: () {
              if (controller.text == '19461') {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 40, backgroundColor: Color(0xFFD4AF37), child: Icon(Icons.person, size: 40, color: Colors.black)),
                    SizedBox(height: 16),
                    Text('Din profil', style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _onHyrelloTap,
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Hyrello', style: TextStyle(color: Colors.white38, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Admin', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _adminTile('Väntande godkännanden', '2 experter', Icons.pending),
          _adminTile('Ärenden / Rapporter', '1 ny', Icons.report),
          _adminTile('Alla konton', 'Visa', Icons.people),
          _adminTile('Felsökning', 'Firebase & Supabase', Icons.bug_report),
        ],
      ),
    );
  }

  Widget _adminTile(String title, String subtitle, IconData icon) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD4AF37)),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () {},
      ),
    );
  }
}
