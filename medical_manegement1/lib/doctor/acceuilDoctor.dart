import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/doctor/notification.dart';

class AcceuilDoctor extends StatefulWidget {
  const AcceuilDoctor({Key? key}) : super(key: key);

  @override
  State<AcceuilDoctor> createState() => _AcceuilDoctorState();
}

class _AcceuilDoctorState extends State<AcceuilDoctor> {
  int? doctorId;

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
  }

  Future<void> _loadDoctorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      doctorId = prefs.getInt('doctorId');
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Affichage de la page d'accueil du médecin");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 227, 227, 227),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align logo and name to the start (left)
          children: [
            Image.asset(
              'assets/logo.png', // Replace with your actual logo path
              height: 30, // Adjust as needed
            ),
            SizedBox(width: 8),
            Text(
              "VosMed",
              style: TextStyle(
                color: Color.fromARGB(255, 2, 196, 176),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications, color: const Color.fromARGB(255, 16, 15, 15)),
                Positioned(
                  right: 0,
                  child: FutureBuilder<int>(
                    future: _getUnreadCount(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data! > 0) {
                        return Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${snapshot.data}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return SizedBox();
                    },
                  ),
                ),
              ],
            ),
            onPressed: () {
              if (doctorId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsPage(),
                  ),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profileDoctor');
              },
              child: Icon(Icons.person, color: const Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCustomButton(
                context,
                "Ajouter/Modifier votre disponibilité",
                Icons.schedule,
                () {
                  print("Bouton 'Ajouter/Modifier disponibilité' cliqué");
                  Navigator.pushNamed(context, '/disponibilite');
                },
              ),
              SizedBox(height: 24),
              _buildCustomButton(
                context,
                "Voir les rendez-vous",
                Icons.calendar_today,
                () {
                  print("Bouton 'Voir les rendez-vous' cliqué");
                  Navigator.pushNamed(context, '/rendezVous');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _getUnreadCount() async {
    if (doctorId == null) return 0;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/doctors/$doctorId/notifications/unread-count/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('count')) {
          return data['count'] as int;
        }
        return 0;
      }
      return 0;
    } catch (e) {
      debugPrint("Erreur lors de la récupération du compteur: $e");
      return 0;
    }
  }

  Widget _buildCustomButton(BuildContext context, String text, IconData icon, VoidCallback onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 2, 196, 176),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}