import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'DoctorAvailabilityPage.dart';
const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');


class DoctorListPage extends StatefulWidget {
  final String city;
  final String specialite;

  DoctorListPage({required this.city, required this.specialite});

  @override
  _DoctorListPageState createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  List<Map<String, dynamic>> doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<int?> _getClientId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('clientId');
  }


  Future<void> _fetchDoctors() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/search-doctors1/?city=${widget.city}&specialite=${widget.specialite}');

    try {
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
          SnackBar(content: Text('Erreur lors de la récupération des médecins')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : doctors.isEmpty
              ? Center(
                  child: Text(
                    "Aucun médecin trouvé pour cette ville et spécialité.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(doctor['nom'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${doctor['specialite']} - ${doctor['localisation']}"),
                        trailing: Icon(Icons.chevron_right, color: Colors.black),
                        onTap: () async {
                          final clientId = await _getClientId();
                          if (clientId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Erreur: Client non identifié")),
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

                              ),
                            );
                          },
                        ),
            );
          }
        }