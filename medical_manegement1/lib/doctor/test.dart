import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<dynamic> doctors = [];

  Future<void> fetchDoctors() async {

    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/doctors/'));

    if (response.statusCode == 200) {
      setState(() {
        doctors = jsonDecode(response.body);
      });
    } else {
      print('Erreur: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du chargement des docteurs')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des Docteurs')),
      body: doctors.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${doctors[index]['nom']} ${doctors[index]['prenom']}'),
            subtitle: Text('Spécialité: ${doctors[index]['specialite']}'),
          );
        },
      ),
    );
  }
}
