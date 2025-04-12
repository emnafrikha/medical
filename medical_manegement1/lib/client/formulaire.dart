import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FormulairePage extends StatefulWidget {
  final int client_id;
  final int doctorId;
  final String doctorName;
  final String selectedDate;
  final String selectedTime;

  const FormulairePage({
    Key? key,
    required this.doctorId,
    required this.client_id,
    required this.doctorName,
    required this.selectedDate,
    required this.selectedTime,
  }) : super(key: key);

  @override
  _FormulairePageState createState() => _FormulairePageState();
}

class _FormulairePageState extends State<FormulairePage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController dateNaissanceController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedGenre = "Homme"; // Genre sélectionné par défaut
  final _formKey = GlobalKey<FormState>();

  // Méthode pour sélectionner une date
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF00BFA5), // Header background color
            hintColor: const Color(0xFF00BFA5), // Accent color
            colorScheme: const ColorScheme.light(primary: const Color(0xFF00BFA5)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateNaissanceController.text =
            DateFormat('yyyy-MM-dd').format(picked); // Format pour Django
      });
    }
  }

  Future<void> enregistrerRendezVous() async {
    if (_formKey.currentState!.validate()) {
      const String apiUrl = "http://10.0.2.2:8000/api/rendezvous/add/"; // Remplace avec ton URL

      Map<String, dynamic> data = {
        "docteur": widget.doctorId, // Remplace avec l'ID du docteur sélectionné
        "client": widget.client_id,
        "nom": nomController.text,
        "prenom": prenomController.text,
        "genre": selectedGenre,
        "date_naissance": dateNaissanceController.text,
        "telephone": telephoneController.text,
        "description_maladie": descriptionController.text,
        "date": widget.selectedDate,
        "heure": widget.selectedTime,
        "statut": "En attente"
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );

        if (response.statusCode == 201) {
          await _sendNotificationToDoctor();
          // Succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Rendez-vous enregistré avec succès !")),
          );
          Navigator.pop(context); // Retourner à l'écran précédent
        } else {
          // Erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur : ${response.body}")),
          );
        }
      } catch (e) {
        print("Erreur: $e");
      }
    }
  }

  Future<void> _sendNotificationToDoctor() async {
    try {
      print("Envoi de la notification..."); // Debug
      final notificationData = {
        "doctor": widget.doctorId,
        "message":
            "${nomController.text} ${prenomController.text} a pris un rendez-vous le ${widget.selectedDate} à ${widget.selectedTime}",
        "appointment_data": jsonEncode({ // Convertir en String pour Django
          "date": widget.selectedDate,
          "time": widget.selectedTime,
          "patient_name": "${nomController.text} ${prenomController.text}",
          "phone": telephoneController.text,
          "description": descriptionController.text,
        }),
        "is_read": false
      };

      print("Données envoyées: $notificationData"); // Debug

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/notification/'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        }, // Imp},
        body: jsonEncode(notificationData),
      );

      print("Réponse du serveur: ${response.statusCode}"); // Debug
      print("Corps de la réponse: ${response.body}"); // Debug

      if (response.statusCode != 201) {
        throw Exception("Échec de l'envoi: ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de l'envoi: $e"); // Debug
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Formulaire de Rendez-vous", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00BFA5),
        iconTheme: IconThemeData(color: Colors.white), // Change back button color
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Rendez-vous chez : Dr. ${widget.doctorName}",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF00BFA5))),
              SizedBox(height: 10),
              Text("Date et heure : ${widget.selectedDate} à ${widget.selectedTime}",
                  style: TextStyle(fontSize: 18, color: Colors.grey[700])),
              SizedBox(height: 30),
              // Nom
              TextFormField(
                controller: nomController,
                decoration: InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Prénom
              TextFormField(
                controller: prenomController,
                decoration: InputDecoration(
                  labelText: "Prénom",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Choix du genre
              DropdownButtonFormField<String>(
                value: selectedGenre,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGenre = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Genre",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.wc),
                ),
                items: <String>['Homme', 'Femme']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Veuillez sélectionner un genre' : null,
              ),
              SizedBox(height: 15),

              // Date de naissance
              TextFormField(
                controller: dateNaissanceController,
                decoration: InputDecoration(
                  labelText: "Date de naissance",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner votre date de naissance';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Numéro de téléphone
              TextFormField(
                controller: telephoneController,
                decoration: InputDecoration(
                  labelText: "Numéro de téléphone",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Description de la maladie (facultatif)
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description de la maladie (facultatif)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 30),

              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    onPressed: enregistrerRendezVous,
                    child: Text("Confirmer", style: TextStyle(color: Colors.white)),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[50],
    );
  }
}