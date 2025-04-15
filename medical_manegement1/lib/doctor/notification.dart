import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Color palette from the NotificationClient design
  final Color primaryColor = Color(0xFF02C4B0);
  final Color backgroundColor = Color(0xFFF8F9FA);
  final Color cardColor = Color(0xFFE8F4F2);

  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  String? errorMessage;
  int? doctorId;

  @override
  void initState() {
    super.initState();
    _loadDoctorIdAndFetchNotifications();
  }

  Future<void> _loadDoctorIdAndFetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedDoctorId = prefs.getInt('doctorId');

      if (storedDoctorId == null || storedDoctorId <= 0) {
        throw Exception('ID du docteur non trouvé ou invalide');
      }

      setState(() {
        doctorId = storedDoctorId;
      });

      await _fetchNotifications();
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      if (doctorId == null || doctorId! <= 0) {
        throw Exception('ID du docteur invalide');
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/doctors/$doctorId/notifications/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = jsonDecode(response.body);

        final parsedNotifications = rawData.map<Map<String, dynamic>>((item) {
          dynamic appointmentData = item['appointment_data'];
          if (appointmentData is String) {
            try {
              appointmentData = jsonDecode(appointmentData);
            } catch (e) {
              appointmentData = {};
            }
          } else if (appointmentData == null) {
            appointmentData = {};
          }

          return {
            'id': item['id'],
            'message': item['message'] ?? 'Nouvelle notification',
            'appointment_data': appointmentData,
            'is_read': item['is_read'] ?? false,
            'created_at': item['created_at'],
            'doctor': item['doctor'],
          };
        }).toList();

        setState(() {
          notifications = parsedNotifications;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appointmentData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Détails du rendez-vous", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Patient", appointmentData['patient_name']?.toString()),
              _buildDetailRow("Date", appointmentData['date']?.toString()),
              _buildDetailRow("Heure", appointmentData['time']?.toString()),
              _buildDetailRow("Téléphone", appointmentData['phone']?.toString()),
              const SizedBox(height: 16),
              Text("Description:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
              const SizedBox(height: 4),
              Text(appointmentData['description']?.toString() ?? 'Aucune description', style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
          ),
          Expanded(child: Text(value ?? 'Non spécifié', style: TextStyle(color: Colors.grey[700]))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              _loadDoctorIdAndFetchNotifications();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)));
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: _loadDoctorIdAndFetchNotifications,
              child: const Text("Réessayer", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "Aucune notification",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Vous n'avez pas de notifications pour le moment",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDoctorIdAndFetchNotifications,
      color: primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final appointmentData = notification['appointment_data'] as Map<String, dynamic>;
    final createdAt = notification['created_at'];

    DateTime? parsedDate;
    String dateText = 'Date inconnue';

    if (createdAt != null) {
      try {
        parsedDate = DateTime.parse(createdAt);
        dateText = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: cardColor,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: primaryColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notification", // Changed to generic notification
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification['message'] as String? ?? 'Notification',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      dateText, // Use the formatted date here
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline, color: primaryColor),
                onPressed: () => _showAppointmentDetails(appointmentData),
              ),
            ],
          ),
        ),
      ),
    );
  }
}