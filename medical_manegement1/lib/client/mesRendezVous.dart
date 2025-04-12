import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MesRendezVousPage extends StatefulWidget {
  final int clientId;

  const MesRendezVousPage({Key? key, required this.clientId}) : super(key: key);

  @override
  _MesRendezVousPageState createState() => _MesRendezVousPageState();
}

class _MesRendezVousPageState extends State<MesRendezVousPage> {
  final Color primaryColor = Color(0xFF02C4B0);
  final Color accentColor = Color(0xFF4CE5D2);
  final Color backgroundColor = Color(0xFFF8F9FA);
  final Color errorColor = Color(0xFFE57373);

  List<dynamic> _rendezVousList = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _fetchRendezVous();
  }

  Future<void> _fetchRendezVous() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/rendezvous/client/${widget.clientId}/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _rendezVousList = data;
          _isLoading = false;
          _isRefreshing = false;
        });
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _annulerRendezVous(int rendezVousId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/rendezvous/$rendezVousId/supprimer/'),
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rendez-vous annulé avec succès'),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _fetchRendezVous();
      } else {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _fetchRendezVous();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Mes Rendez-vous',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : _rendezVousList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucun rendez-vous prévu',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Prenez rendez-vous avec un médecin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: primaryColor,
                  child: _isRefreshing
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _rendezVousList.length,
                          itemBuilder: (context, index) {
                            final rdv = _rendezVousList[index];
                            final isAnnule = rdv['statut'] == 'Annulé';
                            
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
                                color: isAnnule ? Colors.grey[100] : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Dr. ${rdv['docteur_nom'] ?? 'Nom non disponible'}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isAnnule ? Colors.grey : Colors.black,
                                              ),
                                            ),
                                          ),
                                          if (!isAnnule)
                                            IconButton(
                                              icon: Icon(Icons.cancel, color: errorColor),
                                              onPressed: () {
                                                _showAnnulationDialog(rdv['id']);
                                              },
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      _buildInfoRow(Icons.calendar_today, 'Date', rdv['date']),
                                      SizedBox(height: 8),
                                      _buildInfoRow(Icons.access_time, 'Heure', 
                                        rdv['heure'].toString().substring(0, 5)),
                                      SizedBox(height: 8),
                                      _buildInfoRow(Icons.info, 'Statut', rdv['statut'],
                                        statusColor: isAnnule ? Colors.red : primaryColor),
                                      if (rdv['docteur_specialite'] != null)
                                        Column(
                                          children: [
                                            SizedBox(height: 8),
                                            _buildInfoRow(Icons.medical_services, 'Spécialité', 
                                              rdv['docteur_specialite']),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? statusColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: statusColor ?? Colors.grey[600],
        ),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: statusColor ?? Colors.black,
            fontWeight: statusColor != null ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _showAnnulationDialog(int rendezVousId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 50,
                color: errorColor,
              ),
              SizedBox(height: 16),
              Text(
                'Confirmer l\'annulation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Voulez-vous vraiment annuler ce rendez-vous ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Non',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      iconColor: errorColor,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _annulerRendezVous(rendezVousId);
                    },
                    child: Text(
                      'Oui, annuler',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}