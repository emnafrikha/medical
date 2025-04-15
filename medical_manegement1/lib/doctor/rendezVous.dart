import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

class RendezVousPage extends StatefulWidget {
  const RendezVousPage({Key? key}) : super(key: key);

  @override
  _RendezVousPageState createState() => _RendezVousPageState();
}

class _RendezVousPageState extends State<RendezVousPage> {
  List<dynamic> allRendezVous = [];
  bool isLoading = true;
  String? errorMessage;
  int? docteurId;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    debugPrint("[INIT] Initialisation de la page RendezVousPage");
    _selectedDay = DateTime.now();
    _initializeDateFormatting().then((_) => _loadDoctorId());
  }

  Future<void> _initializeDateFormatting() async {
    try {
      await initializeDateFormatting('fr_FR');
      debugPrint("[DATE] Format de date initialisé avec succès");
    } catch (e) {
      debugPrint("[DATE ERREUR] Échec de l'initialisation: $e");
    }
  }

  Future<void> _loadDoctorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      docteurId = prefs.getInt('doctorId');
      debugPrint("[LOAD] ID docteur récupéré: $docteurId");
    });

    if (docteurId == null) {
      debugPrint("[LOAD ERREUR] Aucun ID docteur trouvé");
      setState(() {
        errorMessage = "ID docteur non trouvé";
        isLoading = false;
      });
      return;
    }
    await _fetchRendezVous();
  }

  Future<void> _fetchRendezVous() async {
    debugPrint("[API] Début de la récupération des rendez-vous");
    try {
      final url = "http://10.0.2.2:8000/api/rendezvous/medecin/$docteurId";
      debugPrint("[API] URL appelée: $url");

      final response = await http.get(Uri.parse(url));
      debugPrint("[API] Réponse reçue - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint("[API] Données reçues: ${data.toString()}");
        _processApiData(data);
      } else {
        debugPrint("[API ERREUR] Code statut: ${response.statusCode}");
        setState(() {
          errorMessage = "Erreur serveur: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("[API ERREUR] Exception: $e");
      setState(() {
        errorMessage = "Erreur réseau: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  void _processApiData(List<dynamic> data) {
    debugPrint("[DATA] Traitement des données API");
    final Map<DateTime, List<dynamic>> events = {};

    debugPrint("[DATA] Nombre de RDV reçus: ${data.length}");
    for (var rdv in data) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(rdv['date']);
        final day = DateTime(date.year, date.month, date.day);

        events.putIfAbsent(day, () => []).add(rdv);
        debugPrint("[DATA] RDV ajouté pour le ${day.toString()}");
      } catch (e) {
        debugPrint("[DATA ERREUR] Parsing date pour RDV ${rdv['id']}: $e");
      }
    }

    setState(() {
      allRendezVous = List.from(data);
      _events = events;
      isLoading = false;
    });
    debugPrint("[DATA] Traitement terminé - Jours avec RDV: ${events.length}");
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
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
        color: Colors.grey[50],
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)));
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(8),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              markersAutoAligned: false,  // Allow markers to overlap
              markerSize: 8.0,           // Reduce marker size
              markerMargin: const EdgeInsets.symmetric(horizontal: 1.0),  // Reduce margin around markers
              markerDecoration: BoxDecoration(
                color: Colors.teal[400],
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.teal[200],
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.teal[100],
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false, // Hide format button
              titleCentered: true,         // Center the title
              titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]), // Style the title
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.grey[600]),  // Style left chevron
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.grey[600]), // Style right chevron
            ),
            locale: 'fr_FR',
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildRendezVousList()),
      ],
    );
  }

  Widget _buildRendezVousList() {
    final events = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text("Aucun rendez-vous ce jour", style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
            Text(DateFormat('EEEE d MMMM', 'fr_FR').format(_selectedDay ?? DateTime.now()), style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final rdv = events[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.teal[400]),
            title: Text("${rdv['heure']} - ${rdv['nom']} ${rdv['prenom']}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
            subtitle: Text(rdv['statut'], style: TextStyle(color: Colors.grey[600])),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: () {
              // Handle tap action, perhaps navigate to a details page
              print("Tapped on appointment: ${rdv['id']}");
            },
          ),
        );
      },
    );
  }
}