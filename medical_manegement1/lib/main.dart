import 'package:flutter/material.dart';
import 'package:untitled/client/DoctorListPage.dart';
import 'package:untitled/client/acceuilClient.dart';
import 'package:untitled/client/clientProfile.dart';
import 'package:untitled/client/formulaire.dart';
import 'package:untitled/client/listeVille.dart';
import 'package:untitled/client/mesRendezVous.dart';
import 'package:untitled/doctor/test.dart';
import '../bienvenue.dart';
import '../authentification/se_connecter.dart';
import '../doctor/regestrationDoctor.dart';
import '../doctor/acceuilDoctor.dart';
import '../client/registerClient.dart';
import '../doctor/disponibilite.dart';
import '../doctor/profile_Doctor.dart';
import '../doctor/rendezVous.dart';
import '../doctor/notification.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Route initiale
      routes: {
        '/': (context) => const FirstPage(), // Page initiale
        '/login': (context) => const LoginPage(),
        '/registerDoctor': (context) => RegistrationForm(),
        '/getDoctor': (context) => TestPage(),
        '/acceuilDoctor': (context) =>  AcceuilDoctor(),
        '/registerClient': (context) => ClientRegistrationPage(),
        '/acceuilClient': (context) =>  AcceuilClient(),
        '/disponibilite': (context) =>  DisponibilitePage(),
        '/listeVille': (context) => SelectCityPage(specialite: '',),
        '/DoctorListPage':(context)=> DoctorListPage(city: '', specialite: ''),
        '/profileDoctor': (context) => DoctorProfilePage(),
        '/rendezVous': (context) => RendezVousPage(),
        '/formulaire': (context) => FormulairePage(client_id: 0,doctorId: 0,doctorName: '',selectedDate: '',selectedTime: '',),
        '/clientProfile': (context) => ClientProfilePage(),
        '/mesRendezVous': (context) => MesRendezVousPage(clientId: 0,),
        '/notification': (context) => NotificationsPage(),

      },
    );
  }
}
