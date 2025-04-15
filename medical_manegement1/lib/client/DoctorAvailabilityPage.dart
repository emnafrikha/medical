import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled/client/formulaire.dart';
const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

class DoctorAvailabilityPage extends StatefulWidget {
  final int clientId;
  final int doctorId;
  final String doctorName;
  final String specialite;
  final String localisation;

  const DoctorAvailabilityPage({
    Key? key,
    required this.clientId,
    required this.doctorId,
    required this.doctorName,
    required this.specialite,
    required this.localisation,
  }) : super(key: key);

  @override
  _DoctorAvailabilityPageState createState() => _DoctorAvailabilityPageState();
}

class _DoctorAvailabilityPageState extends State<DoctorAvailabilityPage> {
  final Color _primaryColor = Color.fromARGB(255, 2, 196, 176); // Primary blue
  final Color _secondaryColor = Color.fromARGB(255, 166, 237, 227); // Light blue
  final Color _successColor = Color(0xFF81C784); // Green for available slots
  final Color _errorColor = Color(0xFFE57373); // Red for booked slots
  final Color _disabledColor = Color(0xFFE0E0E0); // Grey for disabled slots

  Map<String, String?> availability = {};
  List<Map<String, dynamic>> appointments = [];
  DateTime _selectedDate = DateTime.now();
  List<String> heures = List.generate(11, (index) => "${(index + 8).toString().padLeft(2, '0')}:00");
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        fetchDisponibilites(widget.doctorId),
        fetchAppointments(widget.doctorId),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement: $e'),
          backgroundColor: _errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> fetchDisponibilites(int doctorId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/disponibilites/$doctorId/'),
    );

    if (response.statusCode == 200) {
      setState(() {
        var data = json.decode(response.body);
        availability = {
          "lundi": data['debut_lundi'] != null && data['fin_lundi'] != null
              ? "${data['debut_lundi']} - ${data['fin_lundi']}"
              : null,
          "mardi": data['debut_mardi'] != null && data['fin_mardi'] != null
              ? "${data['debut_mardi']} - ${data['fin_mardi']}"
              : null,
          "mercredi": data['debut_mercredi'] != null && data['fin_mercredi'] != null
              ? "${data['debut_mercredi']} - ${data['fin_mercredi']}"
              : null,
          "jeudi": data['debut_jeudi'] != null && data['fin_jeudi'] != null
              ? "${data['debut_jeudi']} - ${data['fin_jeudi']}"
              : null,
          "vendredi": data['debut_vendredi'] != null && data['fin_vendredi'] != null
              ? "${data['debut_vendredi']} - ${data['fin_vendredi']}"
              : null,
          "samedi": data['debut_samedi'] != null && data['fin_samedi'] != null
              ? "${data['debut_samedi']} - ${data['fin_samedi']}"
              : null,
          "dimanche": data['debut_dimanche'] != null && data['fin_dimanche'] != null
              ? "${data['debut_dimanche']} - ${data['fin_dimanche']}"
              : null,
        };
      });
    } else {
      throw Exception('Échec de la récupération des disponibilités');
    }
  }

  Future<void> fetchAppointments(int doctorId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/rendezvous/medecin/$doctorId/'),
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      setState(() {
        appointments = List<Map<String, dynamic>>.from(data.map((item) {
          return {
            "id": item["id"].toString(),
            "date": item["date"].toString(),
            "heure": item["heure"].toString().padLeft(5, '0'),
            "statut": item["statut"].toString(),
            "client_id": item["client"]
          };
        }).toList());
      });
    } else {
      throw Exception('Échec de la récupération des rendez-vous');
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    String jourSemaine = _getDayOfWeek(_selectedDate);
    bool isWorkingDay = availability[jourSemaine] != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Disponibilités du Dr. ${widget.doctorName}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              ),
            )
          : Column(
              children: [
                _buildDoctorCard(),
                SizedBox(height: 16),
                _buildCalendar(),
                SizedBox(height: 16),
                Expanded(
                  child: isWorkingDay
                      ? _buildAvailabilityTable(jourSemaine)
                      : _buildNoWorkMessage(),
                ),
              ],
            ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _secondaryColor,
            ),
            child: Icon(
              Icons.person,
              size: 36,
              color: _primaryColor,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${widget.doctorName}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.specialite,
                  style: TextStyle(
                    fontSize: 14,
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      widget.localisation,
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
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        focusedDay: _selectedDate,
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(Duration(days: 30)),
        calendarFormat: CalendarFormat.week,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: _primaryColor),
          rightChevronIcon: Icon(Icons.chevron_right, color: _primaryColor),
          titleTextStyle: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: _primaryColor,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: Colors.grey[600]),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.grey[800]),
          weekendStyle: TextStyle(color: Colors.grey[600]),
        ),
        selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() => _selectedDate = selectedDay);
        },
      ),
    );
  }

  Widget _buildAvailabilityTable(String jourSemaine) {
    List<String> horaires = availability[jourSemaine]!.split('-');
    DateTime heureDebut = _parseHour(horaires[0].trim());
    DateTime heureFin = _parseHour(horaires[1].trim());

    String selectedDateFormatted =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: _primaryColor,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Créneaux disponibles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          ...heures.map((heure) {
            DateTime heureActuelle = _parseHour(heure);

            if (heureActuelle.isBefore(heureDebut) || heureActuelle.isAfter(heureFin)) {
              return _buildTimeSlot(
                heure: heure,
                status: "Non disponible",
                color: _disabledColor,
                textColor: Colors.grey[600]!,
              );
            }

            bool isReserved = appointments.any((appointment) {
              return appointment["date"] == selectedDateFormatted &&
                     appointment["heure"] == heure;
            });

            if (isReserved) {
              return _buildTimeSlot(
                heure: heure,
                status: "Réservé",
                color: _errorColor.withOpacity(0.2),
                textColor: _errorColor,
              );
            }

            return _buildTimeSlot(
              heure: heure,
              status: "Disponible",
              color: _successColor.withOpacity(0.2),
              textColor: _successColor,
              onTap: () => _showAppointmentForm(heure),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeSlot({
    required String heure,
    required String status,
    required Color color,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: textColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  heure,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoWorkMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            "Pas de disponibilité",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Le médecin ne travaille pas ce jour",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getDayOfWeek(DateTime date) {
    List<String> jours = ["dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi"];
    return jours[date.weekday];
  }

  DateTime _parseHour(String heure) {
    List<String> parts = heure.split(":");
    return DateTime(1970, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  void _showAppointmentForm(String heure) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormulairePage(
          client_id: widget.clientId,
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          selectedDate: _selectedDate.toLocal().toString().split(' ')[0],
          selectedTime: heure,
        ),
      ),
    );
  }
}