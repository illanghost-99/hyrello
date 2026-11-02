import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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
      home: const AuthGate(),
    );
  }
}


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;
    if (session != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainAppScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StartScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
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
          Image.asset(
            'assets/handshake_bg.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.45)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const SizedBox(height: 40),
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
              _bigButton(context, "Hyra en expert", false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthChoiceScreen(isExpert: false)))),
              const SizedBox(height: 16),
              _bigButton(context, "Hyra ut mina tjänster", true, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthChoiceScreen(isExpert: true)))),
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
  String? _error;

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
        _error = 'Betalningar är inte tillgängliga på den här enheten';
      });
      return;
    }

    const Set<String> ids = {_productId};
    final response = await _iap.queryProductDetails(ids);

    setState(() {
      _available = true;
      _products = response.productDetails;
      _loading = false;
      if (_products.isEmpty) {
        _error = 'Prenumerationen kunde inte hämtas. Kontrollera App Store Connect.';
      }
    });

    // Listen for purchase updates
    _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
          _iap.completePurchase(purchase);
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen(isExpert: true)));
          }
        } else if (purchase.status == PurchaseStatus.error) {
          setState(() => _error = purchase.error?.message ?? 'Köpet misslyckades');
        }
      }
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
    if (_products.isEmpty) {
      setState(() => _error = 'Produkten är inte tillgänglig');
      return;
    }
    try {
      final purchaseParam = PurchaseParam(productDetails: _products.first);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      setState(() => _error = 'Kunde inte starta köp: $e');
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



class LoginScreen extends StatefulWidget {
  final bool isExpert;
  const LoginScreen({super.key, required this.isExpert});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainAppScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inloggning misslyckades: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Logga in', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _email,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'E-post', labelStyle: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Lösenord', labelStyle: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Logga in', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthChoiceScreen extends StatelessWidget {
  final bool isExpert;
  const AuthChoiceScreen({super.key, required this.isExpert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Konto', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Logga in eller skapa konto', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                try {
                  final credential = await SignInWithApple.getAppleIDCredential(
                    scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
                  );
                  if (credential.identityToken != null) {
                    await Supabase.instance.client.auth.signInWithIdToken(
                      provider: OAuthProvider.apple,
                      idToken: credential.identityToken!,
                    );
                    if (context.mounted) {
                      if (isExpert) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                      } else {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainAppScreen()));
                      }
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Apple-inloggning misslyckades: $e')));
                  }
                }
              },
              icon: const Icon(Icons.apple),
              label: const Text('Logga in med Apple'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (isExpert) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen(isExpert: false)));
                }
              },
              child: const Text('Skapa konto med e-post'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(isExpert: isExpert)));
              },
              child: const Text('Har du redan konto? Logga in', style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ],
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

  Future<void> _next() async {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
          data: {
            'first_name': _firstName.text.trim(),
            'last_name': _lastName.text.trim(),
            'phone': _phone.text.trim(),
            'is_expert': widget.isExpert,
          },
        );
        if (response.user != null && mounted) {
          if (widget.isExpert) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PaymentScreen()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainAppScreen()));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kunde inte skapa konto: $e')));
        }
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
    ChatScreen(),
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
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chatt'),
          NavigationDestination(icon: Icon(Icons.list_outlined), label: 'Lista'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}


class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Chatt', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          _chatTile(context, 'Anna Svensson', 'Hej! När kan du hjälpa mig?', '14:32', false),
          _chatTile(context, 'Erik Lindberg', 'Tack för hjälpen!', 'Igår', true),
          _chatTile(context, 'Sofia Holm', 'Kan vi boka tid?', 'Mån', false),
        ],
      ),
    );
  }

  Widget _chatTile(BuildContext context, String name, String lastMsg, String time, bool read) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: const Color(0xFFD4AF37), child: Text(name[0], style: const TextStyle(color: Colors.black))),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(lastMsg, style: TextStyle(color: read ? Colors.white38 : Colors.white70)),
      trailing: Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(name: name))),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String name;
  const ChatDetailScreen({super.key, required this.name});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hej! Hur kan jag hjälpa dig?', 'mine': false, 'time': '14:30', 'status': 'read'},
    {'text': 'Jag behöver hjälp med ett avtal.', 'mine': true, 'time': '14:31', 'status': 'read'},
  ];

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'text': _controller.text.trim(), 'mine': true, 'time': 'Nu', 'status': 'delivered'});
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'report') _showReportDialog();
              if (v == 'block') ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Användaren är blockerad')));
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'report', child: Text('Rapportera')),
              const PopupMenuItem(value: 'block', child: Text('Blockera')),
            ],
          ),
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
                return Align(
                  alignment: m['mine'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: m['mine'] ? const Color(0xFFD4AF37) : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(m['text'], style: TextStyle(color: m['mine'] ? Colors.black : Colors.white)),
                        const SizedBox(height: 4),
                        Text(m['time'], style: TextStyle(color: m['mine'] ? Colors.black54 : Colors.white38, fontSize: 11)),
                      ],
                    ),
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
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
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

  void _showReportDialog() {
    final reason = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Rapportera', style: TextStyle(color: Color(0xFFD4AF37))),
        content: TextField(controller: reason, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Beskriv problemet')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Avbryt')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rapport skickad till admin')));
            },
            child: const Text('Skicka'),
          ),
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
        title: const Text('Sparade', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Dina sparade experter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(name: name)));
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



class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    final pos = await Geolocator.getCurrentPosition();
    setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
    _mapController.move(_userLocation!, 14);
  }

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
          initialCenter: _userLocation ?? const LatLng(59.3293, 18.0686),
          initialZoom: 13.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'se.HC.hyrello',
          ),
          MarkerLayer(
            markers: [
              if (_userLocation != null)
                Marker(
                  point: _userLocation!,
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ..._experts.map((e) {
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
            ],
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
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['first_name'] ?? 'Användare';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFD4AF37),
              child: const Icon(Icons.person, size: 50, color: Colors.black),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Center(child: Text(user?.email ?? '', style: const TextStyle(color: Colors.white60))),
          const SizedBox(height: 40),
          _profileTile(Icons.edit, 'Redigera profil', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
          _profileTile(Icons.lock, 'Byt lösenord', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
          _profileTile(Icons.image, 'Byt profilbild', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profilbild kan bytas i Redigera profil')))),
          _profileTile(Icons.support_agent, 'Support', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()))),
          _profileTile(Icons.description, 'Användarvillkor', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()))),
          _profileTile(Icons.privacy_tip, 'Integritetspolicy', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen()))),
          const SizedBox(height: 20),
          _profileTile(Icons.logout, 'Logga ut', () async {
            await Supabase.instance.client.auth.signOut();
            if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const StartScreen()), (_) => false);
          }, color: Colors.redAccent),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _onHyrelloTap,
            child: const Center(child: Text('Hyrello', style: TextStyle(color: Colors.white38))),
          ),
        ],
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, VoidCallback onTap, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  bool _loading = false;

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.updateUser(UserAttributes(data: {
        'first_name': _firstName.text.trim(),
        'last_name': _lastName.text.trim(),
      }));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil uppdaterad')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fel: \$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(title: const Text('Redigera profil', style: TextStyle(color: Color(0xFFD4AF37))), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          TextField(controller: _firstName, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Förnamn')),
          const SizedBox(height: 16),
          TextField(controller: _lastName, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Efternamn')),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
            onPressed: _loading ? null : _save,
            child: _loading ? const CircularProgressIndicator() : const Text('Spara'),
          )),
        ]),
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _change() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.updateUser(UserAttributes(password: _password.text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lösenord uppdaterat')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fel: \$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(title: const Text('Byt lösenord', style: TextStyle(color: Color(0xFFD4AF37))), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          TextField(controller: _password, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nytt lösenord')),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
            onPressed: _loading ? null : _change,
            child: _loading ? const CircularProgressIndicator() : const Text('Uppdatera lösenord'),
          )),
        ]),
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(title: const Text('Support', style: TextStyle(color: Color(0xFFD4AF37))), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Kontakta oss', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text('E-post', style: TextStyle(color: Colors.white70)),
          const Text('support@hyrello.se', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16)),
          const SizedBox(height: 16),
          const Text('Telefon', style: TextStyle(color: Colors.white70)),
          const Text('+46 70 123 45 67', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16)),
          const SizedBox(height: 32),
          const Text('AI-support kommer snart i en uppdatering.', style: TextStyle(color: Colors.white54)),
        ]),
      ),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(title: const Text('Användarvillkor', style: TextStyle(color: Color(0xFFD4AF37))), backgroundColor: Colors.transparent),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Text(
          'Användarvillkor för Hyrello\n\n'
          '1. Tjänsten\nHyrello är en plattform för att hyra och erbjuda tjänster.\n\n'
          '2. Användarkonto\nDu ansvarar för att hålla dina inloggningsuppgifter säkra.\n\n'
          '3. Betalning\nPrenumerationer hanteras via App Store.\n\n'
          '4. Ansvar\nHyrello ansvarar inte för tjänster som utförs av användare.\n\n'
          '5. Uppsägning\nDu kan avsluta ditt konto när som helst.',
          style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
        ),
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(title: const Text('Integritetspolicy', style: TextStyle(color: Color(0xFFD4AF37))), backgroundColor: Colors.transparent),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Text(
          'Integritetspolicy för Hyrello\n\n'
          '1. Data vi samlar in\nE-post, namn och profilinformation.\n\n'
          '2. Hur vi använder data\nFör att tillhandahålla tjänsten och förbättra upplevelsen.\n\n'
          '3. Delning\nVi säljer inte dina uppgifter.\n\n'
          '4. Dina rättigheter\nDu kan begära radering av ditt konto.\n\n'
          '5. Kontakt\nsupport@hyrello.se',
          style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
        ),
      ),
    );
  }
}

