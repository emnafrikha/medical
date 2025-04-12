import 'package:flutter/material.dart';
import 'package:untitled/client/DoctorListPage.dart';

class SelectCityPage extends StatefulWidget {
  final String specialite;

  SelectCityPage({Key? key, required this.specialite}) : super(key: key);

  @override
  _SelectCityPageState createState() => _SelectCityPageState();
}

class _SelectCityPageState extends State<SelectCityPage> {
  final List<String> allCities = [
    'Ariana', 'Béja', 'Ben Arous', 'Bizerte', 'Gabès', 'Gafsa', 'Jendouba', 'Kairouan',
    'Kasserine', 'Kébili', 'Kef', 'Mahdia', 'Manouba', 'Médenine', 'Monastir', 'Nabeul',
    'Sfax', 'Sidi Bouzid', 'Siliana', 'Sousse', 'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan'
  ];

  List<String> filteredCities = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCities = List.from(allCities); // Initialize with all cities
  }

  void filterCities(String query) {
    setState(() {
      filteredCities = allCities
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Rechercher une ville...",
                  prefixIcon: Icon(Icons.search, color: Colors.teal[400]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                ),
                onChanged: filterCities,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filteredCities.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[300],
                height: 1,
              ),
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorListPage(city: city, specialite: widget.specialite),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                      child: Text(
                        city,
                        style: TextStyle(fontSize: 16, color: Colors.teal[700]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white, // Very light background
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}