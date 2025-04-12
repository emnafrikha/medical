import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/client/listeVille.dart';
import 'DoctorAvailabilityPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mesRendezVous.dart';
import 'notificationClient.dart';

class AcceuilClient extends StatefulWidget {
  @override
  _AcceuilClientState createState() => _AcceuilClientState();
}

class _AcceuilClientState extends State<AcceuilClient> {
  final List<String> specialites = [
    'Généraliste',
    'Cardiologue',
    'Dermatologue',
    'Pédiatre',
    'Ophtalmologue',
    'Gynécologue',
    'Orthopédiste',
    'Neurologue',
    'Psychiatre',
    'Urologue',
    'Dentiste'
  ];

  List<Map<String, dynamic>> doctors = [];
  bool _isLoading = false;
  int _appointmentCount = 0;

  Future<int?> _getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('clientId');
  }

  Future<void> _fetchClientAppointments() async {
    final clientId = await _getClientId();
    if (clientId == null) return;
    
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/rendezvous/client/$clientId/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _appointmentCount = jsonDecode(response.body).length;
        });
      }
    } catch (e) {
      print("Erreur récupération rendez-vous: $e");
    }
  }

  Future<void> _searchDoctors(String searchTerm) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:8000/api/search-doctors/?search=$searchTerm');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        doctors = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la recherche'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _navigateToMyAppointments() async {
    final clientId = await _getClientId();
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: Client non identifié"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MesRendezVousPage(clientId: clientId),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchClientAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 227, 227, 227),
        elevation: 1,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
            ),
            SizedBox(width: 8),
            Text(
              "VOS MED",
              style: TextStyle(
                color: Color.fromARGB(255, 2, 196, 176),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.calendar_today, color: Colors.black54, size: 28),
                if (_appointmentCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
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
                        '$_appointmentCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            onPressed: _navigateToMyAppointments,
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black54, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationClient()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.person, color: Colors.black54, size: 28),
              onPressed: () {
                Navigator.pushNamed(context, '/clientProfile');
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champ de recherche
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher un médecin...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Color.fromARGB(255, 2, 196, 176)),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                style: TextStyle(color: Colors.black87),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _searchDoctors(value);
                  } else {
                    setState(() {
                      doctors.clear();
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 24),

            // Section Spécialité
            Text(
              "Spécialités médicales",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: specialites.map((specialite) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectCityPage(specialite: specialite),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 227, 241, 239).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color.fromARGB(255, 2, 196, 176).withOpacity(0.3))),
                  child: Text(
                      specialite,
                      style: TextStyle(
                        color: Color.fromARGB(255, 2, 196, 176),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24),

            // Section Résultats de recherche
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 2, 196, 176)),
                ),
              )
            else if (doctors.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return InkWell(
                      onTap: () async {
                        final clientId = await _getClientId();
                        if (clientId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Erreur: Client non identifié"),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorAvailabilityPage(
                              doctorId: doctor['id'],
                              doctorName: doctor['nom'],
                              specialite: doctor['specialite'],
                              localisation: doctor['localisation'],
                              clientId: clientId,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color.fromARGB(255, 2, 196, 176).withOpacity(0.2),
                                radius: 24,
                                child: Icon(
                                  Icons.person,
                                  color: Color.fromARGB(255, 2, 196, 176),
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Dr. ${doctor['nom']}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      doctor['specialite'],
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 2, 196, 176),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Color.fromARGB(255, 2, 196, 176),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          doctor['localisation'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Color.fromARGB(255, 2, 196, 176),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else if (!_isLoading && doctors.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

