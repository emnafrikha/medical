import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    print("Tentative de connexion avec :");
    print("Email: $email");
    print("Mot de passe: $password");

    try {
      final responseDoc = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final responseCli = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/loginClient/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("Réponse du serveur (Médecin): ${responseDoc.statusCode}");
      print("Body (Médecin): ${responseDoc.body}");

      print("Réponse du serveur (Client): ${responseCli.statusCode}");
      print("Body (Client): ${responseCli.body}");

      setState(() {
        _isLoading = false;
      });

      if (responseDoc.statusCode == 200) {
        final data = jsonDecode(responseDoc.body);
        int? doctorId = data["doctor_id"];

        if (doctorId == null) {
          print("Erreur : doctor_id est null !");
          setState(() {
            _errorMessage = "Erreur interne : Identifiant du médecin manquant.";
          });
          return;
        }

        print("Connexion réussie en tant que Médecin !");
        print("Doctor ID: $doctorId");

        await _saveDoctorId(doctorId);
        Navigator.pushReplacementNamed(context, '/acceuilDoctor');
        return;
      }

      if (responseCli.statusCode == 200) {
        final data = jsonDecode(responseCli.body);
        int? clientId = data["client_id"];

        if (clientId == null) {
          print("Erreur : client_id est null !");
          setState(() {
            _errorMessage = "Erreur interne : Identifiant du client manquant.";
          });
          return;
        }

        print("Connexion réussie en tant que Client !");
        print("Client ID: $clientId");

        await _saveClientData(data); // Sauvegarder toutes les données du client
        Navigator.pushReplacementNamed(context, '/acceuilClient');
        return;
      }

      setState(() {
        _errorMessage = "Email ou mot de passe incorrect.";
      });

    } catch (e) {
      print("Erreur lors de la connexion : $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur de connexion. Vérifiez votre réseau.";
      });
    }
  }

  Future<void> _saveDoctorId(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('doctorId', doctorId);
    print("Doctor ID enregistré localement: $doctorId");
  }

  Future<void> _saveClientData(Map<String, dynamic> clientData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('clientId', clientData['client_id']);
    // Sauvegarder toutes les données importantes du client
    if (clientData['email'] != null) {
      await prefs.setString('clientEmail', clientData['email']);
    }
    if (clientData['nom'] != null) {
      await prefs.setString('clientNom', clientData['nom']);
    }
    if (clientData['prenom'] != null) {
      await prefs.setString('clientPrenom', clientData['prenom']);
    }
    if (clientData['telephone'] != null) {
      await prefs.setString('clientTelephone', clientData['telephone']);
    }
    print("Données client enregistrées localement: $clientData");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              // Email Input
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Mot de passe Input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 10),
              ],
              // Bouton Se connecter
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37BDB6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}