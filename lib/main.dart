import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Solid dark background (image removed for now)
          Container(color: const Color(0xFF0A0A0A)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              // Logo
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.35),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Hyrello",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Hitta eller hyra ut expertis",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 60),
              _bigButton(context, "Hyra en expert", false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen(isExpert: false)))),
              const SizedBox(height: 16),
              _bigButton(context, "Hyra ut mina tjänster", true, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()))),
              const SizedBox(height: 8),
              const Text("149 kr/mån", style: TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
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
                side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                foregroundColor: const Color(0xFFD4AF37),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: onPressed,
              child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: const Color(0xFFD4AF37).withOpacity(0.5),
              ),
              onPressed: onPressed,
              child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
    );
  }
}


class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];
  bool _loading = true;

  // Product ID must match what you create in App Store Connect
  static const String _productId = 'hyrello_expert_monthly';

  @override
  void initState() {
    super.initState();
    _initStore();
  }

  Future<void> _initStore() async {
    final available = await _iap.isAvailable();
    if (!available) {
      setState(() {
        _available = false;
        _loading = false;
      });
      return;
    }

    const Set<String> ids = {_productId};
    final response = await _iap.queryProductDetails(ids);

    setState(() {
      _available = true;
      _products = response.productDetails;
      _loading = false;
    });
  }


  Widget _benefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16))),
        ],
      ),
    );
  }

  Future<void> _buy() async {
    if (_products.isEmpty) return;
    final purchaseParam = PurchaseParam(productDetails: _products.first);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    // After purchase (in real app listen to purchaseStream), go to registration
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen(isExpert: true)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Prenumerera', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const Icon(Icons.verified, size: 72, color: Color(0xFFD4AF37)),
                    const SizedBox(height: 16),
                    const Text('Hyrello Expert', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                    const SizedBox(height: 4),
                    const Text('149 kr / månad', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 24),
                    _benefit(Icons.map, 'Synlighet på kartan'),
                    _benefit(Icons.people, 'Ta emot kunder direkt'),
                    _benefit(Icons.star, 'Bygg din professionella profil'),
                    _benefit(Icons.chat, 'Chatt med kunder'),
                    _benefit(Icons.verified_user, 'Verifierad expert-badge'),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _products.isEmpty ? null : _buy,
                        child: Text(
                          _products.isEmpty ? 'Produkt ej tillgänglig' : 'Prenumerera 149 kr/mån',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Avbryt', style: TextStyle(color: Colors.white54)),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                      ),
                  ],
                ),
              ),
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
      if (widget.isExpert) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PaymentScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainAppScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      resizeToAvoidBottomInset: true,
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
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.only(bottom: 80),
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
    _field(_email, 'E-post', keyboard: TextInputType.emailAddress),
    _field(_password, 'Lösenord', obscure: true),
    _field(_firstName, 'Förnamn'),
    _field(_lastName, 'Efternamn'),
    _field(_phone, 'Telefonnummer (+46...)', keyboard: TextInputType.phone),
  ];

  List<Widget> _step2() {
    if (widget.isExpert) {
      return [
        _field(_description, 'Beskrivning om dig (200-250 tecken)', maxLines: 6),
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


class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Prenumeration', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, size: 80, color: Color(0xFFD4AF37)),
            const SizedBox(height: 24),
            const Text('Hyrello Expert', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
            const SizedBox(height: 8),
            const Text('149 kr / månad', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            const Text('Få synlighet på kartan, ta emot kunder och bygg din profil.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                onPressed: () {
                  // Simulate successful payment
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Betalning genomförd!')));
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainAppScreen()));
                },
                child: const Text('Betala 149 kr', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Avbryt', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
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

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Dummy experts with Stockholm-area positions
  final List<Map<String, dynamic>> _experts = [
    {'name': 'Anna Jurist', 'role': 'Juridik', 'lat': 59.334, 'lng': 18.063, 'image': 'https://i.pravatar.cc/150?img=1'},
    {'name': 'Erik Mäklare', 'role': 'Mäklare', 'lat': 59.329, 'lng': 18.068, 'image': 'https://i.pravatar.cc/150?img=3'},
    {'name': 'Lisa Frisör', 'role': 'Frisör', 'lat': 59.338, 'lng': 18.055, 'image': 'https://i.pravatar.cc/150?img=5'},
    {'name': 'Johan IT', 'role': 'IT', 'lat': 59.325, 'lng': 18.072, 'image': 'https://i.pravatar.cc/150?img=8'},
    {'name': 'Sara Läkare', 'role': 'Läkare', 'lat': 59.340, 'lng': 18.050, 'image': 'https://i.pravatar.cc/150?img=9'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Karta', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(59.3293, 18.0686), // Stockholm
          initialZoom: 13.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'se.HC.hyrello',
          ),
          MarkerLayer(
            markers: _experts.map((e) {
              return Marker(
                point: LatLng(e['lat'], e['lng']),
                width: 70,
                height: 90,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ExpertDetailScreen(
                        name: e['name'],
                        title: e['role'],
                        price: 'Från 450 kr/h',
                        desc: 'Erfaren specialist inom ' + e['role'] + '.',
                        rating: 4.8,
                      ),
                    ));
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            e['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          e['name'].split(' ')[0],
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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

