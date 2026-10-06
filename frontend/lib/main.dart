import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

const String baseUrl = 'http://127.0.0.1:8000';

void main() {
  runApp(const SmartChargeApp());
}

// ============================================================
// APP
// ============================================================

class SmartChargeApp extends StatelessWidget {
  const SmartChargeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartCharge EV',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF06110C),
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFF20E879),
              brightness: Brightness.dark,
            ).copyWith(
              primary: const Color(0xFF20E879),
              secondary: const Color(0xFF20E879),
              surface: const Color(0xFF101B14),
              onPrimary: const Color(0xFF041109),
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF06110C),
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF101B14),
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF203128)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0A1510),
          indicatorColor: const Color(0xFF183D29),
          height: 72,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              color: states.contains(WidgetState.selected)
                  ? const Color(0xFF20E879)
                  : Colors.white60,
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? const Color(0xFF20E879)
                  : Colors.white60,
            );
          }),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF20E879),
            foregroundColor: const Color(0xFF041109),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF101B14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2B3B31)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2B3B31)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF20E879), width: 1.5),
          ),
        ),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}

Widget evChargingImage({required double height, double? width}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      height: height,
      width: width,
      child: Image.network(
        'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=1000&q=80',
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => Container(
          color: const Color(0xFF12382B),
          alignment: Alignment.center,
          child: Icon(
            Icons.ev_station_rounded,
            size: height * 0.55,
            color: const Color(0xFF20E879),
          ),
        ),
      ),
    ),
  );
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 20 : 48,
                      vertical: compact ? 20 : 36,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.ev_station,
                              color: Colors.greenAccent,
                              size: 32,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'SmartCharge EV',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => openLogin(context),
                              child: const Text('LOGIN'),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 26 : 42),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: SizedBox(
                            height: compact ? 460 : 520,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=1600&q=85',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: const Color(0xFF12382B),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 35),
                                    child: Icon(
                                      Icons.ev_station,
                                      size: compact ? 115 : 190,
                                      color: Colors.greenAccent.withValues(
                                        alpha: .8,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        const Color(0xFF07140F)
                                            .withValues(alpha: .96),
                                        const Color(0xFF07140F)
                                            .withValues(alpha: .62),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(compact ? 24 : 48),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 570,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'POWER YOUR JOURNEY',
                                            style: TextStyle(
                                              color:
                                                  Colors.greenAccent.shade100,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.bold,
                                              fontSize: compact ? 11 : 13,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Charge smarter.\nDrive greener.',
                                            style: TextStyle(
                                              fontSize: compact ? 34 : 54,
                                              height: 1.05,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          const Text(
                                            'Find nearby EV stations, reserve a charger, and join the queue when every plug is in use.',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 22),
                                          FilledButton.icon(
                                            onPressed: () => openLogin(context),
                                            icon: const Icon(Icons.login),
                                            label: const Text(
                                              'LOGIN TO GET STARTED',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        Text(
                          'A smoother way to charge',
                          style: TextStyle(
                            fontSize: compact ? 24 : 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Plan your stop, keep track of your place, and know when your charger is ready.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: const [
                            _WelcomeFeature(
                              icon: Icons.map_outlined,
                              title: 'Find a station',
                              description: 'Explore nearby charging stations and available plugs.',
                            ),
                            _WelcomeFeature(
                              icon: Icons.format_list_numbered,
                              title: 'Join the queue',
                              description: 'Book your place when all chargers are occupied.',
                            ),
                            _WelcomeFeature(
                              icon: Icons.notifications_active_outlined,
                              title: 'Know when it is your turn',
                              description: 'See your charger assignment as soon as the queue moves.',
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => openLogin(context),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Already have an account? Login'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _WelcomeFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.greenAccent, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// USER SESSION
// ============================================================

class UserSession {
  static int? userId;
  static String? name;
  static String? email;
  static String? phone;
  static String? role;

  static void setUser(Map<String, dynamic> data) {
    userId = data['user_id'];
    name = data['name']?.toString();
    email = data['email']?.toString();
    phone = data['phone']?.toString();
    role = data['role']?.toString();
  }

  static void logout() {
    userId = null;
    name = null;
    email = null;
    phone = null;
    role = null;
  }
}

// ============================================================
// API SERVICE
// ============================================================

class ApiService {
  // ---------------- LOGIN ----------------

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail']?.toString() ?? 'Login failed');
  }

  // ---------------- REGISTER ----------------

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail']?.toString() ?? 'Registration failed');
  }

  // ---------------- NEARBY BEE STATIONS ----------------

  static Future<List<dynamic>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radiusKm = 20,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/stations/nearby'
      '?latitude=${latitude.toStringAsFixed(7)}'
      '&longitude=${longitude.toStringAsFixed(7)}'
      '&radius_km=$radiusKm',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map && data['stations'] is List) {
        return List<dynamic>.from(data['stations']);
      }

      return [];
    }

    throw Exception(
      'Failed to load nearby stations.\n'
      'Status: ${response.statusCode}\n'
      '${response.body}',
    );
  }

  // ---------------- LOCATION SEARCH ----------------

  static Future<Map<String, dynamic>> searchLocation({
    required String query,
    double radiusKm = 10,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/stations/search-location'
      '?query=${Uri.encodeQueryComponent(query)}'
      '&radius_km=$radiusKm',
    );

    final response = await http.get(uri);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data is Map && data['detail'] != null
          ? data['detail'].toString()
          : 'Location search failed',
    );
  }

  // ---------------- FORGOT PASSWORD ----------------

  static Future<Map<String, dynamic>> forgotPassword({
    required String identifier,
    required String method,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'method': method}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail']?.toString() ?? 'Could not send OTP');
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String identifier,
    required String method,
    required String otp,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'method': method,
        'otp': otp,
        'new_password': newPassword,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail']?.toString() ?? 'Password reset failed');
  }

  // ---------------- INTERNAL STATIONS ----------------

  static Future<List<dynamic>> getStations() async {
    final response = await http.get(Uri.parse('$baseUrl/stations'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      if (data is Map && data['stations'] is List) {
        return List<dynamic>.from(data['stations']);
      }

      return [];
    }

    throw Exception('Failed to load stations: ${response.body}');
  }

  // ---------------- HISTORY ----------------

  static Future<List<dynamic>> getHistory(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/charging/history/$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      if (data is Map && data['history'] is List) {
        return List<dynamic>.from(data['history']);
      }

      return [];
    }

    throw Exception(response.body);
  }

  // ---------------- CURRENT CHARGING ----------------

  static Future<dynamic> getCurrentCharging(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/charging/current/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  // ---------------- COMPLETE CHARGING ----------------

  static Future<Map<String, dynamic>> completeCharging(int sessionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/charging/complete/$sessionId'),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data is Map && data['detail'] != null
          ? data['detail'].toString()
          : 'Unable to complete charging',
    );
  }

  // ---------------- CANCEL CHARGING REQUEST ----------------

  static Future<Map<String, dynamic>> cancelCharging(int requestId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/charging/cancel/$requestId'),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data is Map && data['detail'] != null
          ? data['detail'].toString()
          : 'Unable to cancel charging request',
    );
  }

  // ---------------- USER VEHICLES ----------------

  static Future<List<dynamic>> getVehicles(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/vehicles'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is List ? List<dynamic>.from(data) : [];
    }

    throw Exception('Failed to load vehicles: ${response.body}');
  }

  static Future<Map<String, dynamic>> addVehicle({
    required int userId,
    required String vehicleNumber,
    required String model,
    required double batteryCapacity,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/vehicles'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'vehicle_number': vehicleNumber,
        'model': model,
        'battery_capacity': batteryCapacity,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail']?.toString() ?? 'Could not add vehicle');
  }

  // ---------------- BEE BOOKING INFO ----------------

  static Future<Map<String, dynamic>> getBeeBookingInfo(int beeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stations/bee/$beeId/booking'),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data is Map && data['detail'] != null
          ? data['detail'].toString()
          : 'Booking information not available',
    );
  }

  // ---------------- USER QUEUE ----------------

  static Future<List<dynamic>> getUserQueue(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/queue/user/$userId'));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is List) return List<dynamic>.from(data);
      if (data is Map && data['queue'] is List) {
        return List<dynamic>.from(data['queue']);
      }
      return [];
    }

    throw Exception(
      data is Map && data['detail'] != null
          ? data['detail'].toString()
          : 'Unable to load queue',
    );
  }

  static Future<List<dynamic>> getStationQueue(int stationId) async {
    final response = await http.get(Uri.parse('$baseUrl/queue/$stationId'));
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is List) return List<dynamic>.from(data);
      if (data is Map && data['queue'] is List) {
        return List<dynamic>.from(data['queue']);
      }
      return [];
    }

    throw Exception(
      data is Map && data['detail'] != null
          ? data['detail'].toString()
          : 'Unable to load station queue',
    );
  }

  // ---------------- CREATE CHARGING REQUEST ----------------

  static Future<Map<String, dynamic>> createChargingRequest({
    required int userId,
    required int vehicleId,
    required int stationId,
    required double batteryNow,
    required double batteryRequired,
    required DateTime arrivalTime,
    required DateTime departureTime,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/charging/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'vehicle_id': vehicleId,
        'station_id': stationId,
        'battery_now': batteryNow,
        'battery_required': batteryRequired,
        'arrival_time': arrivalTime.toIso8601String(),
        'departure_time': departureTime.toIso8601String(),
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    final detail = data is Map ? data['detail'] : null;
    final message = detail is Map
        ? detail['message']?.toString()
        : detail?.toString();
    throw Exception(message ?? 'Booking failed');
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter email and password.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await ApiService.login(email: email, password: password);

      UserSession.setUser(result);

      if (!mounted) return;
      TextInput.finishAutofillContext(shouldSave: true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserSession.role == 'admin'
              ? const AdminDashboardPage()
              : const HomePage(),
        ),
      );
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: AutofillGroup(
                  child: Column(
                    children: [
                      evChargingImage(height: 72, width: 112),
                      const SizedBox(height: 12),
                      const Text(
                        'SmartCharge EV',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Smart EV Charging & Station Finder',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 30),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!loading) login();
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: const [
                          Expanded(child: Divider(color: Colors.white30)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.white60),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white30)),
                        ],
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Google Sign-In will be connected with Firebase next.',
                                ),
                              ),
                            );
                          },
                          icon: Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'G',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          label: const Text('Continue with Google'),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Apple Sign-In will be connected with Firebase next.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.apple, size: 23),
                          label: const Text('Continue with Apple'),
                        ),
                      ),

                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text("Don't have an account? Register"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FORGOT PASSWORD PAGE
// ============================================================

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final identifierController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String method = 'email';
  bool otpSent = false;
  bool loading = false;
  bool hideNewPassword = true;
  bool hideConfirmPassword = true;

  Future<void> sendOtp() async {
    final identifier = identifierController.text.trim();
    if (identifier.isEmpty) {
      showMessage('Please enter your email or phone number.');
      return;
    }

    setState(() => loading = true);
    try {
      final result = await ApiService.forgotPassword(
        identifier: identifier,
        method: method,
      );

      if (!mounted) return;
      setState(() => otpSent = true);

      final demoOtp = result['demo_otp']?.toString();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('OTP Sent'),
          content: Text(
            demoOtp == null
                ? 'OTP has been sent to your registered ${method == 'email' ? 'email' : 'phone number'}.'
                : 'Local testing OTP: $demoOtp\n\nIn production this OTP will be delivered by email/SMS.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resetPassword() async {
    final identifier = identifierController.text.trim();
    final otp = otpController.text.trim();
    final password = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (otp.length != 6) {
      showMessage('Please enter the 6-digit OTP.');
      return;
    }
    if (password.length < 6) {
      showMessage('Password must contain at least 6 characters.');
      return;
    }
    if (password != confirm) {
      showMessage('Passwords do not match.');
      return;
    }

    setState(() => loading = true);
    try {
      await ApiService.resetPassword(
        identifier: identifier,
        method: method,
        otp: otp,
        newPassword: password,
      );

      if (!mounted) return;
      showMessage('Password reset successful. Please login.');
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    identifierController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_reset,
                      size: 70,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose email or phone number to receive OTP.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 25),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'email',
                          icon: Icon(Icons.email),
                          label: Text('Email'),
                        ),
                        ButtonSegment(
                          value: 'phone',
                          icon: Icon(Icons.phone),
                          label: Text('Phone'),
                        ),
                      ],
                      selected: {method},
                      onSelectionChanged: (value) {
                        setState(() => method = value.first);
                      },
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: identifierController,
                      keyboardType: method == 'email'
                          ? TextInputType.emailAddress
                          : TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: method == 'email'
                            ? 'Registered Email'
                            : 'Registered Phone Number',
                        prefixIcon: Icon(
                          method == 'email' ? Icons.email : Icons.phone,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loading ? null : sendOtp,
                        child: loading && !otpSent
                            ? const CircularProgressIndicator()
                            : const Text('SEND OTP'),
                      ),
                    ),
                    if (otpSent) ...[
                      const SizedBox(height: 25),
                      TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: '6-Digit OTP',
                          prefixIcon: Icon(Icons.verified_user),
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: newPasswordController,
                        obscureText: hideNewPassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => hideNewPassword = !hideNewPassword,
                            ),
                            icon: Icon(
                              hideNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: hideConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => hideConfirmPassword = !hideConfirmPassword,
                            ),
                            icon: Icon(
                              hideConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : resetPassword,
                          child: loading
                              ? const CircularProgressIndicator()
                              : const Text('RESET PASSWORD'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTER PAGE
// ============================================================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      showMessage('Please fill all fields.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await ApiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful. Please login.')),
      );

      Navigator.pop(context);
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_add,
                      size: 65,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loading ? null : register,
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(),
                              )
                            : const Text(
                                'CREATE ACCOUNT',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ADMIN DASHBOARD
// ============================================================

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<List<dynamic>> stationsFuture;
  late Future<List<dynamic>> historyFuture;

  @override
  void initState() {
    super.initState();
    stationsFuture = ApiService.getStations();
    historyFuture = ApiService.getHistory(UserSession.userId ?? 0);
  }

  Future<void> refresh() async {
    setState(() {
      stationsFuture = ApiService.getStations();
      historyFuture = ApiService.getHistory(UserSession.userId ?? 0);
    });
    await Future.wait([stationsFuture, historyFuture]);
  }

  Future<void> logout() async {
    UserSession.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget metric(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.greenAccent),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EV Charging Admin'),
        actions: [
          IconButton(onPressed: refresh, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Live SmartCharge overview',
              style: TextStyle(color: Colors.white.withOpacity(.65)),
            ),
            const SizedBox(height: 18),
            FutureBuilder<List<dynamic>>(
              future: stationsFuture,
              builder: (_, snap) {
                final count = snap.data?.length ?? 0;
                return Row(
                  children: [
                    metric('Stations', '$count', Icons.ev_station),
                    const SizedBox(width: 10),
                    metric(
                      'Live Data',
                      snap.connectionState == ConnectionState.waiting
                          ? '...'
                          : 'ON',
                      Icons.wifi_tethering,
                    ),
                    const SizedBox(width: 10),
                    metric('Role', 'ADMIN', Icons.admin_panel_settings),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<dynamic>>(
              future: historyFuture,
              builder: (_, snap) {
                final count = snap.data?.length ?? 0;
                return Row(
                  children: [
                    metric('Your Sessions', '$count', Icons.bolt),
                    const SizedBox(width: 10),
                    metric('Queue', 'Live', Icons.queue),
                    const SizedBox(width: 10),
                    metric('Reports', 'Ready', Icons.analytics),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Station Overview',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<dynamic>>(
                      future: stationsFuture,
                      builder: (_, snap) {
                        if (snap.connectionState == ConnectionState.waiting)
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        final items = snap.data ?? [];
                        if (items.isEmpty)
                          return const Text('No stations available.');
                        return Column(
                          children: items
                              .take(10)
                              .map(
                                (s) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.ev_station),
                                  ),
                                  title: Text(
                                    s['station_name']?.toString() ??
                                        s['name']?.toString() ??
                                        'Station',
                                  ),
                                  subtitle: Text(
                                    s['address']?.toString() ??
                                        s['location']?.toString() ??
                                        '-',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Charging Sessions',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<dynamic>>(
                      future: historyFuture,
                      builder: (_, snap) {
                        final items = snap.data ?? [];
                        if (items.isEmpty)
                          return const Text('No charging sessions available.');
                        return Column(
                          children: items
                              .take(6)
                              .map(
                                (item) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.bolt,
                                    color: Colors.greenAccent,
                                  ),
                                  title: Text(
                                    item['station_name']?.toString() ??
                                        'Charging Station',
                                  ),
                                  subtitle: Text(
                                    'Request ${item['request_id'] ?? '-'} • ${item['status'] ?? '-'}',
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StationMapPage()),
                    ),
                    icon: const Icon(Icons.ev_station),
                    label: const Text('STATIONS'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    ),
                    icon: const Icon(Icons.analytics),
                    label: const Text('REPORTS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  void openQueue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QueuePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(onQueueTap: openQueue),
      const StationMapPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// USER DASHBOARD
// ============================================================

class DashboardPage extends StatefulWidget {
  final VoidCallback? onQueueTap;

  const DashboardPage({super.key, this.onQueueTap});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const double fallbackLatitude = 16.3067;
  static const double fallbackLongitude = 80.4365;

  dynamic currentCharging;
  List<dynamic> nearbyStations = [];
  int waitingQueueCount = 0;
  bool loadingQueueCount = true;
  String? queueCountError;
  bool loading = true;

  bool loadingStations = false;
  bool usingFallbackStationLocation = false;
  String? nearbyStationsError;
  Timer? queueAssignmentTimer;
  bool checkingQueueAssignment = false;
  String? previouslyObservedChargingStatus;
  String? previouslyObservedRequestId;
  String? lastNotifiedRequestId;

  @override
  void initState() {
    super.initState();
    loadDashboard();
    queueAssignmentTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => checkForQueueAssignment(),
    );
  }

  @override
  void dispose() {
    queueAssignmentTimer?.cancel();
    super.dispose();
  }

  Future<void> loadDashboard() async {
    await Future.wait([
      loadCurrentCharging(),
      loadNearbyStations(),
      loadWaitingQueueCount(),
    ]);
  }

  Future<void> loadWaitingQueueCount() async {
    final userId = UserSession.userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          waitingQueueCount = 0;
          loadingQueueCount = false;
          queueCountError = null;
        });
      }
      return;
    }

    try {
      final requests = await ApiService.getUserQueue(userId);
      if (!mounted) return;
      setState(() {
        waitingQueueCount = requests
            .where(
              (request) =>
                  request is Map &&
                  request['status']?.toString().toLowerCase() == 'waiting',
            )
            .length;
        loadingQueueCount = false;
        queueCountError = null;
      });
    } catch (error) {
      debugPrint('Could not refresh waiting queue count: $error');
      if (!mounted) return;
      setState(() {
        loadingQueueCount = false;
        queueCountError = error.toString();
      });
    }
  }

  Future<void> loadCurrentCharging() async {
    final id = UserSession.userId;

    if (id == null) {
      if (mounted)
        setState(() {
          currentCharging = null;
          loading = false;
        });
      return;
    }

    try {
      final result = await ApiService.getCurrentCharging(id);
      if (!mounted) return;
      setState(() {
        currentCharging = result is Map<String, dynamic>
            ? result
            : Map<String, dynamic>.from(result as Map);
        loading = false;
      });
      previouslyObservedChargingStatus = _chargingStatus(result);
      previouslyObservedRequestId = _chargingRequestId(result);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        currentCharging = null;
        loading = false;
      });
      previouslyObservedChargingStatus = null;
      previouslyObservedRequestId = null;
    }
  }

  String? _chargingStatus(dynamic result) {
    if (result is! Map ||
        result['active'] != true ||
        result['charging'] is! Map) {
      return null;
    }
    return result['charging']['status']?.toString().toLowerCase();
  }

  String? _chargingRequestId(dynamic result) {
    if (result is! Map ||
        result['active'] != true ||
        result['charging'] is! Map) {
      return null;
    }
    return result['charging']['request_id']?.toString();
  }

  Future<void> checkForQueueAssignment() async {
    final id = UserSession.userId;
    if (id == null || checkingQueueAssignment) return;
    checkingQueueAssignment = true;
    try {
      await loadWaitingQueueCount();
      final result = await ApiService.getCurrentCharging(id);
      if (!mounted) return;

      final status = _chargingStatus(result);
      final wasWaiting = previouslyObservedChargingStatus == 'waiting';
      final previousRequestId = previouslyObservedRequestId;
      final isAssigned = status == 'allocated' || status == 'charging';
      final charging = result is Map && result['charging'] is Map
          ? Map<String, dynamic>.from(result['charging'])
          : <String, dynamic>{};
      final requestId = charging['request_id']?.toString();

      setState(() {
        currentCharging = result is Map<String, dynamic>
            ? result
            : Map<String, dynamic>.from(result as Map);
      });
      previouslyObservedChargingStatus = status;
      previouslyObservedRequestId = requestId;

      if ((wasWaiting || requestId != previousRequestId) &&
          isAssigned &&
          requestId != null &&
          requestId != lastNotifiedRequestId) {
        lastNotifiedRequestId = requestId;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Your turn is ready! Charger ${charging['charger_id'] ?? ''} has been assigned to you.',
              ),
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'VIEW',
                onPressed: () => showCurrentCharging(),
              ),
            ),
          );
      }
    } catch (error) {
      debugPrint('Queue assignment check failed: $error');
    } finally {
      checkingQueueAssignment = false;
    }
  }

  Future<void> loadNearbyStations() async {
    if (!mounted) return;
    setState(() {
      loadingStations = true;
      nearbyStationsError = null;
    });

    var latitude = fallbackLatitude;
    var longitude = fallbackLongitude;
    var usingFallback = true;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      var permission = await Geolocator.checkPermission();

      if (serviceEnabled && permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (serviceEnabled &&
          (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always)) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );
        latitude = position.latitude;
        longitude = position.longitude;
        usingFallback = false;
      }
    } catch (error) {
      debugPrint('Could not get location for nearby stations: $error');
    }

    try {
      final result = await ApiService.getNearbyStations(
        latitude: latitude,
        longitude: longitude,
        radiusKm: 20,
      );
      if (!mounted) return;
      setState(() {
        nearbyStations = result.take(5).toList();
        usingFallbackStationLocation = usingFallback;
      });
    } catch (error) {
      debugPrint('Could not load nearby stations: $error');
      if (mounted) {
        setState(() {
          nearbyStations = [];
          nearbyStationsError = error.toString();
          usingFallbackStationLocation = usingFallback;
        });
      }
    } finally {
      if (mounted) setState(() => loadingStations = false);
    }
  }

  Future<void> logout() async {
    UserSession.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void openStationMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StationMapPage()),
    );
  }

  Widget sectionTitle(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        if (onViewAll != null)
          TextButton(onPressed: onViewAll, child: const Text('View all')),
      ],
    );
  }

  Widget nearbyCard(Map<String, dynamic> station) {
    final name = station['cpo_name']?.toString() ?? 'EV Station';
    final distance = station['distance_km']?.toString() ?? '-';
    final type = station['charger_type']?.toString() ?? 'Charger';
    final rating = station['charger_rating']?.toString() ?? '-';
    final connectors = station['connector_count']?.toString() ?? '-';
    final location = [station['city_village'], station['district']]
        .where((part) => part != null && part.toString().trim().isNotEmpty)
        .join(', ');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: openStationMap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF17452D), Color(0xFF10251A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.ev_station_rounded,
                  size: 34,
                  color: Color(0xFF20E879),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.isEmpty ? '$type charging' : location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 10,
                      runSpacing: 3,
                      children: [
                        _stationAttribute(
                          Icons.near_me_outlined,
                          '$distance km',
                        ),
                        _stationAttribute(
                          Icons.bolt,
                          '$rating kW · $connectors plugs',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stationAttribute(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF20E879)),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget statCard(IconData icon, String value, String label) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 7),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF20E879), size: 23),
              const SizedBox(height: 7),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget currentChargingCard() {
    final active = currentCharging is Map && currentCharging['active'] == true;
    final charging = active && currentCharging['charging'] is Map
        ? Map<String, dynamic>.from(currentCharging['charging'])
        : <String, dynamic>{};

    return Card(
      child: InkWell(
        onTap: showCurrentCharging,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.battery_charging_full,
                  color: Colors.greenAccent,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Charging',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      loading
                          ? 'Checking current session...'
                          : active
                          ? '${charging['status']?.toString().toUpperCase() ?? 'ACTIVE'} • Request ${charging['request_id'] ?? '-'}'
                          : 'No active charging request',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showCurrentCharging() async {
    final id = UserSession.userId;
    if (id == null) return;

    try {
      final result = await ApiService.getCurrentCharging(id);
      if (!mounted) return;

      final active = result is Map && result['active'] == true;
      final charging = active && result['charging'] is Map
          ? Map<String, dynamic>.from(result['charging'])
          : <String, dynamic>{};

      if (!active) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Current Charging'),
            content: const Text('No active charging request found.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        );
        return;
      }

      final requestId = charging['request_id']?.toString() ?? '-';
      final sessionId = int.tryParse(charging['session_id']?.toString() ?? '');
      final stationId = charging['station_id']?.toString() ?? '-';
      final vehicleId = charging['vehicle_id']?.toString() ?? '-';
      final chargerId = charging['charger_id']?.toString() ?? '-';
      final batteryNow = charging['battery_now']?.toString() ?? '-';
      final batteryRequired = charging['battery_required']?.toString() ?? '-';
      final status = charging['status']?.toString() ?? 'unknown';
      final arrivalTime = charging['arrival_time']?.toString() ?? '-';
      final departureTime = charging['departure_time']?.toString() ?? '-';
      final startTime = charging['start_time']?.toString() ?? '-';

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Current Charging'),
          content: SizedBox(
            width: 470,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 14,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  detailRow('Station ID', stationId),
                  detailRow('Charger ID', chargerId),
                  detailRow('Vehicle ID', vehicleId),
                  const Divider(height: 25),
                  const Text(
                    'Battery',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.battery_charging_full,
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$batteryNow% → $batteryRequired%',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  detailRow('Arrival', arrivalTime),
                  detailRow('Departure', departureTime),
                  detailRow('Started', startTime),
                  const Divider(height: 25),
                  detailRow('Request ID', requestId),
                ],
              ),
            ),
          ),
          actions: [
            if (sessionId != null &&
                (status == 'allocated' || status == 'charging'))
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Cancel Booking?'),
                      content: const Text(
                        'Are you sure you want to cancel this charging request?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('NO'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('YES, CANCEL'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !mounted) return;
                  try {
                    await ApiService.cancelCharging(int.parse(requestId));
                    if (!mounted) return;
                    Navigator.pop(context);
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Booking Cancelled'),
                        content: const Text(
                          'Your charging request was cancelled and the charger is available for another EV.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    await loadDashboard();
                  } catch (e) {
                    if (mounted) showMessage(e.toString());
                  }
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('CANCEL'),
              ),
            if (sessionId != null &&
                (status == 'allocated' || status == 'charging'))
              ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Finish Charging?'),
                      content: const Text(
                        'Confirm that your EV has finished charging.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('NOT YET'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('YES, CHARGED'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !mounted) return;
                  try {
                    final result = await ApiService.completeCharging(sessionId);
                    if (!mounted) return;
                    Navigator.pop(context);
                    final nextRequestId = result['next_request_id'];
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Charging Completed'),
                        content: Text(
                          nextRequestId != null
                              ? 'Charging completed. The charger has been allocated to the next queued EV.\n\nNext Request ID: $nextRequestId'
                              : 'Charging completed. The charger is now AVAILABLE for another EV.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    await loadDashboard();
                  } catch (e) {
                    if (mounted) showMessage(e.toString());
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('CHARGED'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) showMessage(e.toString());
    }
  }

  Widget detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final name = UserSession.name ?? 'User';
    final active = currentCharging is Map && currentCharging['active'] == true;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: const Color(0xFF163D28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Color(0xFF20E879),
                size: 25,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'SmartCharge',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              onPressed: loadDashboard,
              tooltip: 'Refresh charging status',
              icon: const Icon(Icons.refresh_rounded),
            ),
            IconButton(
              onPressed: logout,
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Text(
              'Hello, $name',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ready for a smarter, greener drive?',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 17),
            TextField(
              readOnly: true,
              onTap: openStationMap,
              decoration: InputDecoration(
                hintText: 'Search charging stations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.tune),
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF27563A)),
                gradient: const LinearGradient(
                  colors: [Color(0xFF173D28), Color(0xFF10251A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Power your journey\nwith clean energy.',
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Find a nearby charger and get back on the road.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: openStationMap,
                          icon: const Icon(Icons.near_me_outlined, size: 18),
                          label: const Text('FIND A STATION'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2013),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2D6743)),
                    ),
                    child: const Icon(
                      Icons.electric_car_rounded,
                      size: 44,
                      color: Color(0xFF20E879),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            sectionTitle('Your charging at a glance'),
            Row(
              children: [
                statCard(
                  Icons.location_on_outlined,
                  '${nearbyStations.length}',
                  'Stations nearby',
                ),
                const SizedBox(width: 9),
                statCard(
                  Icons.battery_charging_full,
                  active ? '1' : '0',
                  'Active session',
                ),
                const SizedBox(width: 9),
                statCard(
                  Icons.hourglass_bottom_rounded,
                  loadingQueueCount
                      ? '...'
                      : queueCountError != null
                      ? '!'
                      : '$waitingQueueCount',
                  'In queue',
                ),
              ],
            ),
            const SizedBox(height: 16),
            currentChargingCard(),
            const SizedBox(height: 20),
            sectionTitle('Nearby Charging Stations', onViewAll: openStationMap),
            if (loadingStations)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (nearbyStationsError != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Color(0xFFFFB74D),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Could not load stations. $nearbyStationsError',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      IconButton(
                        onPressed: loadNearbyStations,
                        tooltip: 'Retry loading stations',
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                ),
              )
            else if (nearbyStations.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, color: Color(0xFF20E879)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No chargers found within 20 km of this location. Try again or explore the map.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      TextButton(
                        onPressed: openStationMap,
                        child: const Text('OPEN MAP'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              if (usingFallbackStationLocation)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Showing stations near Guntur. Allow location access to see chargers near you.',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
              ...nearbyStations.map(
                (station) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: nearbyCard(Map<String, dynamic>.from(station)),
                ),
              ),
            ],
            const SizedBox(height: 10),
            sectionTitle('Quick Actions'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.map_outlined,
                      color: Color(0xFF20E879),
                    ),
                    title: const Text('Find a charger'),
                    subtitle: const Text('Browse nearby charging stations'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: openStationMap,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(
                      Icons.queue_rounded,
                      color: Color(0xFF20E879),
                    ),
                    title: const Text('My queue'),
                    subtitle: const Text('View position or manage a booking'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap:
                        widget.onQueueTap ??
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QueuePage()),
                        ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFF20E879),
                    ),
                    title: const Text('Charging history'),
                    subtitle: const Text('Review your previous sessions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// QUEUE STATUS
// ============================================================

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  late Future<List<Map<String, dynamic>>> queueFuture;
  Timer? queueRefreshTimer;
  Timer? queueCountdownTimer;

  @override
  void initState() {
    super.initState();
    queueFuture = loadQueueOverview();
    queueRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        setState(() => queueFuture = loadQueueOverview());
      }
    });
    queueCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    queueRefreshTimer?.cancel();
    queueCountdownTimer?.cancel();
    super.dispose();
  }

  String _formatQueueWait(dynamic estimatedStartTime) {
    final startTime = DateTime.tryParse(estimatedStartTime?.toString() ?? '');
    if (startTime == null) return 'Calculating wait time...';

    final secondsRemaining = startTime.difference(DateTime.now()).inSeconds;
    if (secondsRemaining <= 0) return 'Expected soon';

    final duration = Duration(seconds: secondsRemaining);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return 'Estimated wait: ${hours}h ${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    }
    return 'Estimated wait: ${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  Future<List<Map<String, dynamic>>> loadQueueOverview() async {
    final userId = UserSession.userId;
    if (userId == null) {
      throw Exception('Please log in again to view your queue.');
    }

    final myRequests = await ApiService.getUserQueue(userId);
    final stationIds = myRequests
        .map((request) => int.tryParse(request['station_id']?.toString() ?? ''))
        .whereType<int>()
        .toSet();

    try {
      final bookings = await ApiService.getHistory(userId);
      for (final booking in bookings) {
        if (booking is! Map) continue;
        final status = booking['status']?.toString().toLowerCase();
        if (status != 'waiting' &&
            status != 'allocated' &&
            status != 'charging') {
          continue;
        }
        final stationId = int.tryParse(booking['station_id']?.toString() ?? '');
        if (stationId != null) stationIds.add(stationId);
      }
    } catch (error) {
      debugPrint('Could not load active booking stations for queue: $error');
    }

    final stationQueues = await Future.wait(
      stationIds.map((stationId) async {
        final rawEntries = await ApiService.getStationQueue(stationId);
        final entries = <Map<String, dynamic>>[];
        for (final rawEntry in rawEntries) {
          if (rawEntry is! Map) continue;
          final entry = Map<String, dynamic>.from(rawEntry);
          final serverEta = DateTime.tryParse(
            entry['estimated_start_time']?.toString() ?? '',
          );

          if (serverEta != null) {
            entry['estimated_start_time'] = serverEta.toIso8601String();
          }
          entries.add(entry);
        }
        final ownRequests = myRequests
            .where(
              (request) =>
                  int.tryParse(request['station_id']?.toString() ?? '') ==
                  stationId,
            )
            .map((request) => Map<String, dynamic>.from(request))
            .toList();
        return {
          'station_id': stationId,
          'entries': entries,
          'own_requests': ownRequests,
        };
      }),
    );
    return stationQueues;
  }

  Future<void> refresh() async {
    setState(() => queueFuture = loadQueueOverview());
    await queueFuture;
  }

  Future<void> cancelWaitingRequest(
    int requestId, {
    required bool chooseAnotherStation,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          chooseAnotherStation ? 'Choose another station?' : 'Cancel booking?',
        ),
        content: Text(
          chooseAnotherStation
              ? 'Your place in this station queue will be cancelled so you can book at another station.'
              : 'Are you sure you want to leave the charging queue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('KEEP MY PLACE'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(chooseAnotherStation ? 'CONTINUE' : 'CANCEL BOOKING'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ApiService.cancelCharging(requestId);
      if (!mounted) return;
      await refresh();
      if (!mounted) return;
      if (chooseAnotherStation) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Queue booking cancelled.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StationMapPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your queue booking has been cancelled.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not cancel queue booking: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Queue Status')),
      body: FutureBuilder<List<dynamic>>(
        future: queueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(
              child: Text(
                'Could not load queue.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          final stationQueues = snapshot.data ?? [];
          if (stationQueues.isEmpty) {
            return RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 220),
                  Center(
                    child: Text('You are not currently waiting in a queue.'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'Users waiting for a charger',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...stationQueues.map((stationQueue) {
                  final stationId = stationQueue['station_id'];
                  final entries = List<dynamic>.from(
                    stationQueue['entries'] as List,
                  );
                  final ownRequests = List<Map<String, dynamic>>.from(
                    stationQueue['own_requests'] as List,
                  );
                  final ownByRequestId = {
                    for (final request in ownRequests)
                      request['request_id']?.toString(): request,
                  };

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.ev_station,
                              color: Colors.greenAccent,
                            ),
                            title: Text('Station $stationId'),
                            subtitle: Text('${entries.length} user(s) waiting'),
                          ),
                          const Divider(),
                          if (entries.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('No users are currently waiting.'),
                            ),
                          ...entries.map((rawItem) {
                            final item = Map<String, dynamic>.from(rawItem);
                            final requestId =
                                item['request_id']?.toString() ?? '';
                            final ownRequest = ownByRequestId[requestId];
                            final isMine = ownRequest != null;
                            final numericRequestId = int.tryParse(requestId);
                            final userName = item['user_name']?.toString();
                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    child: Text(
                                      '${item['queue_position'] ?? '-'}',
                                    ),
                                  ),
                                  title: Text(
                                    userName != null && userName.isNotEmpty
                                        ? '$userName${isMine ? ' (you)' : ''}'
                                        : isMine
                                        ? 'Your vehicle'
                                        : 'Waiting user',
                                  ),
                                  subtitle: Text(
                                    'Request $requestId • ${item['vehicle_number'] ?? 'EV'} • ${isMine ? 'Your booking' : 'Waiting'}',
                                  ),
                                  trailing: isMine
                                      ? const Chip(label: Text('YOU'))
                                      : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 52,
                                    right: 8,
                                    bottom: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.hourglass_bottom_rounded,
                                        size: 16,
                                        color: Color(0xFF20E879),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatQueueWait(
                                          item['estimated_start_time'],
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isMine && numericRequestId != null)
                                  Wrap(
                                    alignment: WrapAlignment.end,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => cancelWaitingRequest(
                                          numericRequestId,
                                          chooseAnotherStation: false,
                                        ),
                                        icon: const Icon(Icons.cancel_outlined),
                                        label: const Text('CANCEL BOOKING'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () => cancelWaitingRequest(
                                          numericRequestId,
                                          chooseAnotherStation: true,
                                        ),
                                        icon: const Icon(Icons.map_outlined),
                                        label: const Text(
                                          'SELECT ANOTHER STATION',
                                        ),
                                      ),
                                    ],
                                  ),
                                const Divider(),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              child: Text(
                (UserSession.name ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              UserSession.name ?? 'User',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              UserSession.email ?? '',
              style: const TextStyle(color: Colors.white60),
            ),
          ),
          const SizedBox(height: 25),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(UserSession.email ?? '-'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone'),
              subtitle: Text(UserSession.phone ?? '-'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Vehicles'),
              subtitle: const Text('Manage your saved EV vehicles'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final id = UserSession.userId;
                if (id == null) return;
                final vehicles = await ApiService.getVehicles(id);
                if (!context.mounted) return;
                showModalBottomSheet(
                  context: context,
                  builder: (_) => SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Text(
                          'My Vehicles',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (vehicles.isEmpty)
                          const Text('No vehicles added yet.'),
                        ...vehicles.map(
                          (v) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.electric_car),
                              title: Text('${v['vehicle_number'] ?? '-'}'),
                              subtitle: Text(
                                '${v['model'] ?? '-'} • ${v['battery_capacity'] ?? '-'} kWh',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Charging History'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.queue),
              title: const Text('Queue Status'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QueuePage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATION MAP PAGE
// ============================================================

class StationMapPage extends StatefulWidget {
  const StationMapPage({super.key});

  @override
  State<StationMapPage> createState() => _StationMapPageState();
}

class _StationMapPageState extends State<StationMapPage> {
  final MapController mapController = MapController();

  Position? currentPosition;

  List<dynamic> stations = [];

  Map<String, dynamic>? selectedStation;

  List<LatLng> routePoints = [];

  StreamSubscription<Position>? positionSubscription;

  bool _mapReady = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    initializeLocation();
  }

  @override
  void dispose() {
    positionSubscription?.cancel();
    super.dispose();
  }

  // ==========================================================
  // LOCATION
  // ==========================================================

  Future<void> initializeLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }

        showError(
          'Location service is OFF.\n\n'
          'Please enable GPS/location.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }

        showError('Location permission denied.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }

        showError(
          'Location permission is permanently denied.\n\n'
          'Please enable location permission in browser/device settings.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        loading = false;
      });

      await loadNearbyStations();

      startLiveLocation();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showError('Could not get current location.\n\n$e');
    }
  }

  // ==========================================================
  // LIVE LOCATION
  // ==========================================================

  void startLiveLocation() {
    positionSubscription?.cancel();

    positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          if (!mounted) return;

          setState(() {
            currentPosition = position;
          });

          if (selectedStation != null) {
            loadRoute();
          }
        });
  }

  // ==========================================================
  // BEE STATIONS
  // ==========================================================

  Future<void> loadNearbyStations() async {
    final position = currentPosition;

    if (position == null) return;

    try {
      final result = await ApiService.getNearbyStations(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusKm: 20,
      );

      if (!mounted) return;

      setState(() {
        stations = result;
      });
    } catch (e) {
      if (mounted) {
        showError('Could not load nearby stations.\n\n$e');
      }
    }
  }

  // ==========================================================
  // SEARCH STATION BY ENTERED LOCATION
  // ==========================================================

  Future<void> searchByEnteredLocation() async {
    final controller = TextEditingController();
    double radiusKm = 10;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool searching = false;
        String? error;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Search Station by Location'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter a city, village or location.\nExample: Vijayawada, Gudlavalleru',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Enter Location',
                      hintText: 'e.g. Vijayawada',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<double>(
                    value: radiusKm,
                    decoration: const InputDecoration(
                      labelText: 'Search Radius',
                      border: OutlineInputBorder(),
                    ),
                    items: const [5, 10, 20, 50]
                        .map(
                          (value) => DropdownMenuItem<double>(
                            value: value.toDouble(),
                            child: Text('$value km'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) radiusKm = value;
                    },
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: searching
                      ? null
                      : () async {
                          final query = controller.text.trim();
                          if (query.isEmpty) {
                            setDialogState(() => error = 'Enter a location.');
                            return;
                          }

                          setDialogState(() {
                            searching = true;
                            error = null;
                          });

                          try {
                            final data = await ApiService.searchLocation(
                              query: query,
                              radiusKm: radiusKm,
                            );

                            final latitude = (data['latitude'] as num)
                                .toDouble();
                            final longitude = (data['longitude'] as num)
                                .toDouble();
                            final foundStations = List<dynamic>.from(
                              data['stations'] ?? [],
                            );

                            if (!mounted) return;
                            setState(() {
                              currentPosition = Position(
                                longitude: longitude,
                                latitude: latitude,
                                timestamp: DateTime.now(),
                                accuracy: 0,
                                altitude: 0,
                                altitudeAccuracy: 0,
                                heading: 0,
                                headingAccuracy: 0,
                                speed: 0,
                                speedAccuracy: 0,
                                floor: null,
                                isMocked: false,
                              );
                              stations = foundStations;
                              selectedStation = null;
                              routePoints = [];
                            });

                            moveMapSafely(latitude, longitude, 12);

                            Navigator.pop(dialogContext);

                            if (foundStations.isEmpty) {
                              showMessage(
                                'No BEE EV stations found within ${radiusKm.toInt()} km of $query.',
                              );
                            } else {
                              showStationSearchResults(
                                foundStations,
                                data['resolved_location']?.toString() ?? query,
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              searching = false;
                              error = e.toString();
                            });
                          }
                        },
                  icon: searching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: const Text('SEARCH'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  void showStationSearchResults(List<dynamic> results, String locationName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.70,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 10, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.greenAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Stations near $locationName',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final station = Map<String, dynamic>.from(results[index]);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.ev_station),
                          ),
                          title: Text(
                            station['cpo_name']?.toString() ?? 'EV Station',
                          ),
                          subtitle: Text(
                            '${station['city_village'] ?? '-'}, ${station['district'] ?? '-'}\n'
                            '${station['distance_km'] ?? '-'} km • '
                            '${station['charger_type'] ?? '-'}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            selectStation(station);
                            showStationDetails();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // SAFE MAP MOVE
  // ==========================================================

  void moveMapSafely(double latitude, double longitude, double zoom) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!_mapReady) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            moveMapSafely(latitude, longitude, zoom);
          }
        });
        return;
      }

      try {
        mapController.move(LatLng(latitude, longitude), zoom);
      } catch (e) {
        debugPrint('Map move skipped: $e');
      }
    });
  }

  // ==========================================================
  // SELECT STATION
  // ==========================================================

  Future<void> selectStation(Map<String, dynamic> station) async {
    setState(() {
      selectedStation = station;
      routePoints = [];
    });

    final lat = double.tryParse(station['latitude'].toString());

    final lng = double.tryParse(station['longitude'].toString());

    if (lat == null || lng == null) return;

    moveMapSafely(lat, lng, 15);

    await loadRoute();
  }

  // ==========================================================
  // ROAD ROUTE
  // ==========================================================

  Future<void> loadRoute() async {
    final position = currentPosition;
    final station = selectedStation;

    if (position == null || station == null) {
      return;
    }

    final stationLat = double.tryParse(station['latitude'].toString());

    final stationLng = double.tryParse(station['longitude'].toString());

    if (stationLat == null || stationLng == null) {
      return;
    }

    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${position.longitude},${position.latitude};'
        '$stationLng,$stationLat'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return;
      }

      final data = jsonDecode(response.body);

      final routes = data['routes'];

      if (routes == null || routes is! List || routes.isEmpty) {
        return;
      }

      final coordinates = routes[0]['geometry']['coordinates'];

      final points = <LatLng>[];

      for (final coordinate in coordinates) {
        if (coordinate is List && coordinate.length >= 2) {
          points.add(
            LatLng(
              (coordinate[1] as num).toDouble(),
              (coordinate[0] as num).toDouble(),
            ),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        routePoints = points;
      });
    } catch (e) {
      debugPrint('Route error: $e');
    }
  }

  // ==========================================================
  // CENTER USER
  // ==========================================================

  void centerOnUser() {
    final position = currentPosition;

    if (position == null) return;

    moveMapSafely(position.latitude, position.longitude, 15);
  }

  // ==========================================================
  // STATION DETAILS
  // ==========================================================

  void showStationDetails() {
    final station = selectedStation;

    if (station == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.ev_station,
                        color: Colors.greenAccent,
                        size: 35,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          station['cpo_name']?.toString() ?? 'EV Station',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  detailRow('BEE ID', station['bee_id']),

                  detailRow('Ownership', station['ownership']),

                  detailRow('State', station['state']),

                  detailRow('District', station['district']),

                  detailRow('City / Village', station['city_village']),

                  detailRow('Location', station['location']),

                  detailRow('Distance', '${station['distance_km'] ?? '-'} km'),

                  detailRow('Charger Type', station['charger_type']),

                  detailRow('Charger Rating', station['charger_rating']),

                  detailRow('Connector Rating', station['connector_rating']),

                  detailRow('Connector Count', station['connector_count']),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        startBookingForBeeStation(
                          Map<String, dynamic>.from(station),
                        );
                      },
                      icon: const Icon(Icons.ev_station),
                      label: const Text('BOOK CHARGER'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // BOOKING FLOW
  // ==========================================================

  Future<void> startBookingForBeeStation(
    Map<String, dynamic> beeStation,
  ) async {
    final beeId = int.tryParse(beeStation['bee_id'].toString());
    final userId = UserSession.userId;

    if (beeId == null) {
      showError('Invalid BEE station ID.');
      return;
    }

    if (userId == null) {
      showError('Please login again before booking.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 18),
            Expanded(child: Text('Checking station booking availability...')),
          ],
        ),
      ),
    );

    try {
      final bookingInfo = await ApiService.getBeeBookingInfo(beeId);
      final vehicles = await ApiService.getVehicles(userId);

      if (!mounted) return;
      Navigator.pop(context);

      if (vehicles.isEmpty) {
        await showAddVehicleDialog();
        if (!mounted) return;
        final refreshedVehicles = await ApiService.getVehicles(userId);
        if (refreshedVehicles.isEmpty) {
          showMessage('Please add a vehicle before booking.');
          return;
        }
        await showBookingDialog(bookingInfo, refreshedVehicles);
        return;
      }

      await showBookingDialog(bookingInfo, vehicles);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showError('Could not start booking.\n\n$e');
      }
    }
  }

  Future<void> showAddVehicleDialog() async {
    final userId = UserSession.userId;
    if (userId == null) return;

    final numberController = TextEditingController();
    final modelController = TextEditingController();
    final batteryController = TextEditingController();
    bool saving = false;
    String? error;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Your EV Vehicle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add a vehicle first to continue with charging booking.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: numberController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Number',
                        hintText: 'e.g. AP39AB1234',
                        prefixIcon: Icon(Icons.directions_car),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: modelController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Model',
                        hintText: 'e.g. Tata Nexon EV',
                        prefixIcon: Icon(Icons.electric_car),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: batteryController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Battery Capacity (kWh)',
                        hintText: 'e.g. 40.5',
                        prefixIcon: Icon(Icons.battery_charging_full),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final number = numberController.text.trim();
                          final model = modelController.text.trim();
                          final battery = double.tryParse(
                            batteryController.text.trim(),
                          );

                          if (number.isEmpty ||
                              model.isEmpty ||
                              battery == null ||
                              battery <= 0) {
                            setDialogState(
                              () => error = 'Enter valid vehicle details.',
                            );
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                            error = null;
                          });

                          try {
                            await ApiService.addVehicle(
                              userId: userId,
                              vehicleNumber: number,
                              model: model,
                              batteryCapacity: battery,
                            );
                            if (mounted) Navigator.pop(dialogContext);
                          } catch (e) {
                            setDialogState(() {
                              saving = false;
                              error = e.toString();
                            });
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ADD VEHICLE'),
                ),
              ],
            );
          },
        );
      },
    );

    numberController.dispose();
    modelController.dispose();
    batteryController.dispose();
  }

  Future<void> showBookingDialog(
    Map<String, dynamic> bookingInfo,
    List<dynamic> vehicles,
  ) async {
    final userId = UserSession.userId;
    if (userId == null) return;

    int? selectedVehicleId = int.tryParse(
      vehicles.first['vehicle_id'].toString(),
    );
    final batteryNowController = TextEditingController();
    final batteryRequiredController = TextEditingController();
    DateTime arrivalTime = DateTime.now().add(const Duration(minutes: 10));
    DateTime departureTime = DateTime.now().add(const Duration(hours: 2));
    bool submitting = false;
    String? error;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String formatDateTime(DateTime value) {
              final local = value.toLocal();
              final hh = local.hour.toString().padLeft(2, '0');
              final mm = local.minute.toString().padLeft(2, '0');
              return '${local.day.toString().padLeft(2, '0')}/'
                  '${local.month.toString().padLeft(2, '0')}/'
                  '${local.year} $hh:$mm';
            }

            Future<void> pickArrival() async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: arrivalTime,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (pickedDate == null) return;

              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(arrivalTime),
              );
              if (pickedTime == null) return;

              setDialogState(() {
                arrivalTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                if (!departureTime.isAfter(arrivalTime)) {
                  departureTime = arrivalTime.add(const Duration(hours: 1));
                }
              });
            }

            Future<void> pickDeparture() async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: departureTime,
                firstDate: arrivalTime,
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (pickedDate == null) return;

              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(departureTime),
              );
              if (pickedTime == null) return;

              setDialogState(() {
                departureTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
              });
            }

            Future<void> submitBooking() async {
              final vehicleId = selectedVehicleId;
              final batteryNow = double.tryParse(
                batteryNowController.text.trim(),
              );
              final batteryRequired = double.tryParse(
                batteryRequiredController.text.trim(),
              );
              final stationId = int.tryParse(
                bookingInfo['station_id'].toString(),
              );

              if (vehicleId == null || stationId == null) {
                setDialogState(() => error = 'Please select a vehicle.');
                return;
              }
              if (batteryNow == null || batteryNow < 0 || batteryNow > 100) {
                setDialogState(
                  () => error = 'Battery Now must be between 0 and 100%.',
                );
                return;
              }
              if (batteryRequired == null ||
                  batteryRequired < 0 ||
                  batteryRequired > 100) {
                setDialogState(
                  () => error = 'Battery Required must be between 0 and 100%.',
                );
                return;
              }
              if (batteryRequired <= batteryNow) {
                setDialogState(
                  () => error =
                      'Battery Required must be greater than Battery Now.',
                );
                return;
              }
              if (!departureTime.isAfter(arrivalTime)) {
                setDialogState(
                  () => error = 'Departure time must be after arrival time.',
                );
                return;
              }

              setDialogState(() {
                submitting = true;
                error = null;
              });

              try {
                final result = await ApiService.createChargingRequest(
                  userId: userId,
                  vehicleId: vehicleId,
                  stationId: stationId,
                  batteryNow: batteryNow,
                  batteryRequired: batteryRequired,
                  arrivalTime: arrivalTime,
                  departureTime: departureTime,
                );

                if (!mounted) return;
                Navigator.pop(dialogContext);
                showBookingResult(result, bookingInfo);
              } catch (e) {
                setDialogState(() {
                  submitting = false;
                  error = e.toString().replaceFirst(
                    RegExp(r'^Exception:\s*'),
                    '',
                  );
                });
              }
            }

            final chargerList = bookingInfo['chargers'] is List
                ? List<dynamic>.from(bookingInfo['chargers'])
                : <dynamic>[];
            final availableCount = chargerList
                .where((c) => c is Map && c['status'] == 'available')
                .length;

            return AlertDialog(
              title: Text(
                'Book Charger - ${bookingInfo['station_name'] ?? 'EV Station'}',
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              evChargingImage(
                                height: 96,
                                width: double.infinity,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                bookingInfo['station_name']?.toString() ??
                                    'EV Station',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${bookingInfo['city_village'] ?? '-'}, ${bookingInfo['district'] ?? '-'}',
                              ),
                              Text(
                                'Charger: ${bookingInfo['bee_charger_type'] ?? '-'} • ${bookingInfo['bee_charger_rating'] ?? '-'} kW',
                              ),
                              Text('Available chargers: $availableCount'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedVehicleId,
                        decoration: const InputDecoration(
                          labelText: 'Select Vehicle (saved vehicle)',
                          helperText: 'Your vehicle details are saved. Select them instead of entering again.',
                          prefixIcon: Icon(Icons.electric_car),
                          border: OutlineInputBorder(),
                        ),
                        items: vehicles
                            .map<DropdownMenuItem<int>>((vehicle) {
                              final id = int.tryParse(
                                vehicle['vehicle_id'].toString(),
                              );
                              final number =
                                  vehicle['vehicle_number']?.toString() ?? '-';
                              final model = vehicle['model']?.toString() ?? '-';
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text('$number • $model'),
                              );
                            })
                            .where((item) => item.value != null)
                            .toList(),
                        onChanged: submitting
                            ? null
                            : (value) => setDialogState(
                                () => selectedVehicleId = value,
                              ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: submitting
                              ? null
                              : () async {
                                  await showAddVehicleDialog();
                                  if (!mounted) return;
                                  final refreshed =
                                      await ApiService.getVehicles(userId);
                                  if (refreshed.isNotEmpty) {
                                    setDialogState(() {
                                      vehicles
                                        ..clear()
                                        ..addAll(refreshed);
                                      selectedVehicleId = int.tryParse(
                                        refreshed.last['vehicle_id'].toString(),
                                      );
                                    });
                                  }
                                },
                          icon: const Icon(Icons.add),
                          label: const Text('ADD NEW VEHICLE'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: batteryNowController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Battery Now (%)',
                          hintText: 'e.g. 25',
                          prefixIcon: Icon(Icons.battery_3_bar),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: batteryRequiredController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Battery Required (%)',
                          hintText: 'e.g. 80',
                          prefixIcon: Icon(Icons.battery_full),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.login),
                        title: const Text('Arrival Time'),
                        subtitle: Text(formatDateTime(arrivalTime)),
                        trailing: const Icon(Icons.edit_calendar),
                        onTap: submitting ? null : pickArrival,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.logout),
                        title: const Text('Departure Time'),
                        subtitle: Text(formatDateTime(departureTime)),
                        trailing: const Icon(Icons.edit_calendar),
                        onTap: submitting ? null : pickDeparture,
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton.icon(
                  onPressed: submitting ? null : submitBooking,
                  icon: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(submitting ? 'BOOKING...' : 'CONFIRM BOOKING'),
                ),
              ],
            );
          },
        );
      },
    );

    batteryNowController.dispose();
    batteryRequiredController.dispose();
  }

  void showBookingResult(
    Map<String, dynamic> result,
    Map<String, dynamic> bookingInfo,
  ) {
    final status = result['status']?.toString() ?? 'unknown';
    final requestId = result['request_id']?.toString() ?? '-';
    final chargerId = result['charger_id']?.toString();
    final queuePosition = result['queue_position']?.toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(
              status == 'allocated' ? Icons.check_circle : Icons.hourglass_top,
              color: status == 'allocated'
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                status == 'allocated' ? 'Booking Confirmed' : 'Added to Queue',
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Station: ${bookingInfo['station_name'] ?? '-'}'),
              const SizedBox(height: 8),
              Text('Request ID: $requestId'),
              if (chargerId != null) ...[
                const SizedBox(height: 8),
                Text('Charger ID: $chargerId'),
              ],
              if (queuePosition != null) ...[
                const SizedBox(height: 8),
                Text('Queue Position: $queuePosition'),
              ],
              const SizedBox(height: 12),
              Text(
                result['message']?.toString() ??
                    'Booking processed successfully.',
              ),
              if (status == 'waiting') ...[
                const SizedBox(height: 10),
                const Text(
                  'Your booking is in the queue. When the current charging user taps FINISHED, the charger is assigned to the first request in line. You can keep your place, cancel, or cancel and choose another station.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
        actionsOverflowDirection: VerticalDirection.up,
        actionsOverflowButtonSpacing: 8,
        actions: [
          if (status == 'waiting') ...[
            TextButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Cancel queue booking?'),
                    content: const Text(
                      'Your place in the queue will be cancelled. You can then book at another station.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('KEEP MY PLACE'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('CANCEL AND CHOOSE'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !mounted) return;
                try {
                  await ApiService.cancelCharging(int.parse(requestId));
                  if (!mounted) return;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StationMapPage()),
                  );
                } catch (error) {
                  if (mounted) showMessage('Could not cancel booking: $error');
                }
              },
              icon: const Icon(Icons.map_outlined),
              label: const Text('CHANGE STATION'),
            ),
            TextButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Cancel queue booking?'),
                    content: const Text(
                      'Are you sure you want to leave the charging queue?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('KEEP MY PLACE'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('CANCEL BOOKING'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !mounted) return;
                try {
                  await ApiService.cancelCharging(int.parse(requestId));
                  if (!mounted) return;
                  Navigator.pop(context);
                  showMessage('Your queue booking has been cancelled.');
                } catch (error) {
                  if (mounted) showMessage('Could not cancel booking: $error');
                }
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('CANCEL BOOKING'),
            ),
          ],
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  Widget detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? '-')),
        ],
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================================
  // MAP
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final position = currentPosition;

    final center = position == null
        ? const LatLng(16.3067, 80.4365)
        : LatLng(position.latitude, position.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find EV Stations'),
        actions: [
          IconButton(
            tooltip: 'Search by location',
            onPressed: searchByEnteredLocation,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () async {
              await loadNearbyStations();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 13,
                    onMapReady: () {
                      _mapReady = true;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/'
                          '{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.smartcharge.smartchargeev',
                    ),

                    // ROUTE
                    if (routePoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 5,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),

                    // MARKERS
                    MarkerLayer(
                      markers: [
                        // USER
                        if (position != null)
                          Marker(
                            point: LatLng(
                              position.latitude,
                              position.longitude,
                            ),
                            width: 55,
                            height: 55,
                            child: const Icon(
                              Icons.my_location,
                              size: 40,
                              color: Colors.blueAccent,
                            ),
                          ),

                        // STATIONS
                        ...stations
                            .map<Marker?>((station) {
                              final lat = double.tryParse(
                                station['latitude'].toString(),
                              );

                              final lng = double.tryParse(
                                station['longitude'].toString(),
                              );

                              if (lat == null || lng == null) {
                                return null;
                              }

                              final selected =
                                  selectedStation != null &&
                                  selectedStation!['bee_id'] ==
                                      station['bee_id'];

                              return Marker(
                                point: LatLng(lat, lng),
                                width: 55,
                                height: 65,
                                child: GestureDetector(
                                  onTap: () {
                                    selectStation(
                                      Map<String, dynamic>.from(station),
                                    );
                                  },
                                  child: Icon(
                                    Icons.ev_station,
                                    size: selected ? 48 : 38,
                                    color: selected
                                        ? Colors.orangeAccent
                                        : Colors.greenAccent,
                                  ),
                                ),
                              );
                            })
                            .whereType<Marker>()
                            .toList(),
                      ],
                    ),

                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),

                // TOP INFO
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${stations.length} EV stations found nearby',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // USER LOCATION BUTTON
                Positioned(
                  right: 15,
                  bottom: 170,
                  child: FloatingActionButton(
                    heroTag: 'current_location',
                    onPressed: centerOnUser,
                    child: const Icon(Icons.my_location),
                  ),
                ),

                // SELECTED STATION
                if (selectedStation != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.ev_station,
                                  color: Colors.greenAccent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    selectedStation!['cpo_name']?.toString() ??
                                        'EV Station',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedStation = null;
                                      routePoints = [];
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),

                            Text(
                              '${selectedStation!['city_village'] ?? '-'}, '
                              '${selectedStation!['district'] ?? '-'}',
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Distance: '
                              '${selectedStation!['distance_km'] ?? '-'} km',
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: showStationDetails,
                                    icon: const Icon(Icons.info_outline),
                                    label: const Text('Details'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: loadRoute,
                                    icon: const Icon(Icons.route),
                                    label: const Text('Route'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

// ============================================================
// HISTORY PAGE
// ============================================================

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<dynamic>> historyFuture;

  @override
  void initState() {
    super.initState();

    historyFuture = ApiService.getHistory(UserSession.userId ?? 0);
  }

  Future<void> refreshHistory() async {
    setState(() {
      historyFuture = ApiService.getHistory(UserSession.userId ?? 0);
    });

    await historyFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Charging History')),
      body: FutureBuilder<List<dynamic>>(
        future: historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 50),
                    const SizedBox(height: 15),
                    Text(
                      'Could not load history.\n\n'
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: refreshHistory,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return RefreshIndicator(
              onRefresh: refreshHistory,
              child: ListView(
                children: const [
                  SizedBox(height: 250),
                  Center(child: Text('No charging history yet.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: refreshHistory,
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];

                final status = item['status']?.toString() ?? 'unknown';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        status == 'completed'
                            ? Icons.check
                            : status == 'charging'
                            ? Icons.bolt
                            : status == 'waiting'
                            ? Icons.hourglass_empty
                            : Icons.ev_station,
                      ),
                    ),
                    title: Text(
                      item['station_name']?.toString() ?? 'Charging Station',
                    ),
                    subtitle: Text(
                      'Request: '
                      '${item['request_id'] ?? '-'}\n'
                      'Status: '
                      '${status.toUpperCase()}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
