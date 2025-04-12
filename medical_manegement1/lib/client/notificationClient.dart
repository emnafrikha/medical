import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationClient extends StatefulWidget {
  @override
  _NotificationClientState createState() => _NotificationClientState();
}

class _NotificationClientState extends State<NotificationClient> {
  final Color primaryColor = Color(0xFF02C4B0);
  final Color backgroundColor = Color(0xFFF8F9FA);
  final Color cardColor = Color(0xFFE8F4F2);

  List<String> notifications = [];
  bool _isLoading = true;

  Future<int?> _getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('clientId');
  }

  Future<void> _fetchNotifications() async {
    final clientId = await _getClientId();
    if (clientId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/rendezvous/client/$clientId/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> rendezvous = jsonDecode(response.body);
        DateTime demain = DateTime.now().add(Duration(days: 1));

        List<String> notificationsTemp = [];
        for (var rdv in rendezvous) {
          DateTime rdvDate = DateTime.parse(rdv['date']);
          String rdvHeure = rdv['heure'].substring(0, 5);

          if (rdvDate.year == demain.year &&
              rdvDate.month == demain.month &&
              rdvDate.day == demain.day) {
            notificationsTemp.add(
                "N'oubliez pas votre rendez-vous demain à $rdvHeure chez Dr. ${rdv['docteur_nom']}.");
          }
        }

        setState(() {
          notifications = notificationsTemp;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur récupération notifications: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
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
            icon: Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
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
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  color: primaryColor,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(notifications[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationCard(String notification) {
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
                      "Rappel de rendez-vous",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Aujourd'hui",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}