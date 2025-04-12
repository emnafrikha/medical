import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DisponibilitePage extends StatefulWidget {
  @override
  _DisponibilitePageState createState() => _DisponibilitePageState();
}

class _DisponibilitePageState extends State<DisponibilitePage> {
  int? doctorId;
  String apiUrl = "http://10.0.2.2:8000/api/disponibilites/";
  bool isLoading = true;
  String? errorMessage;

  // Initialisation à null comme dans votre demande
  Map<String, String?> disponibilites = {
    "debut_lundi": null,
    "fin_lundi": null,
    "debut_mardi": null,
    "fin_mardi": null,
    "debut_mercredi": null,
    "fin_mercredi": null,
    "debut_jeudi": null,
    "fin_jeudi": null,
    "debut_vendredi": null,
    "fin_vendredi": null,
    "debut_samedi": null,
    "fin_samedi": null,
    "debut_dimanche": null,
    "fin_dimanche": null,
  };

  // Liste des heures disponibles (format "HH:00")
  List<String> heures = List.generate(11, (index) => "${(index + 8).toString().padLeft(2, '0')}:00");

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      doctorId = prefs.getInt("doctorId");
    });

    if (doctorId != null) {
      _fetchDisponibilites();
    } else {
      setState(() {
        isLoading = false;
        errorMessage = "ID du docteur non trouvé.";
      });
    }
  }

  Future<void> _fetchDisponibilites() async {
    if (doctorId == null) return;

    try {
      final response = await http.get(
        Uri.parse("$apiUrl$doctorId/"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          for (var key in disponibilites.keys) {
            disponibilites[key] = data[key]?.toString();
          }
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // Nouveau médecin sans disponibilités enregistrées
        setState(() => isLoading = false);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Erreur lors de la récupération.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion.";
      });
    }
  }

  Future<void> _submitDisponibilites() async {
    debugPrint("[DEBUG] Tentative d'envoi des disponibilités");
    debugPrint("[DEBUG] Données à envoyer: $disponibilites");

    if (doctorId == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse("${apiUrl}add/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "docteur": doctorId,
          ...disponibilites,
        }),
      );
      debugPrint("[DEBUG] Réponse du serveur - Status: ${response.statusCode}");
      debugPrint("[DEBUG] Corps de la réponse: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Disponibilités enregistrées avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          errorMessage = errorData['error'] ?? "Erreur lors de l'enregistrement";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur de connexion: ${e.toString()}";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  String? _getValidValue(String? value) {
    return heures.contains(value) ? value : null;
  }

  Widget _buildTimeSlot(String day, String startKey, String endKey) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color.fromARGB(255, 2, 196, 176)),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "De",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        value: _getValidValue(disponibilites[startKey]),
                        items: heures.map((time) => DropdownMenuItem(
                              value: time,
                              child: Text(time, style: TextStyle(color: Colors.grey[800])),
                            )).toList(),
                        onChanged: (value) => setState(() => disponibilites[startKey] = value),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "À",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        value: _getValidValue(disponibilites[endKey]),
                        items: heures.map((time) => DropdownMenuItem(
                              value: time,
                              child: Text(time, style: TextStyle(color: Colors.grey[800])),
                            )).toList(),
                        onChanged: (value) => setState(() => disponibilites[endKey] = value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        )),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 2, 196, 176))))
            : Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    Expanded(
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          _buildTimeSlot("Lundi", "debut_lundi", "fin_lundi"),
                          _buildTimeSlot("Mardi", "debut_mardi", "fin_mardi"),
                          _buildTimeSlot("Mercredi", "debut_mercredi", "fin_mercredi"),
                          _buildTimeSlot("Jeudi", "debut_jeudi", "fin_jeudi"),
                          _buildTimeSlot("Vendredi", "debut_vendredi", "fin_vendredi"),
                          _buildTimeSlot("Samedi", "debut_samedi", "fin_samedi"),
                          _buildTimeSlot("Dimanche", "debut_dimanche", "fin_dimanche"),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitDisponibilites,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 2, 196, 176),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                         minimumSize: Size(200, 50),
                      ),
                      child: Text(
                        "Enregistrer",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}