import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherPage extends StatefulWidget {
  final String fileName;

  WeatherPage({required this.fileName});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  List<Map<String, String>> _weatherReports = [];
  bool _isLoading = true;
  int _currentLayoutIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final storageRef = FirebaseStorage.instance.ref().child('uploads/${widget.fileName}');
    try {
      final downloadUrl = await storageRef.getDownloadURL();
      final response = await http.get(Uri.parse(downloadUrl));
      var bytes = response.bodyBytes;
      var excel = Excel.decodeBytes(bytes);

      List<Map<String, String>> locations = [];

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          if (row.isNotEmpty) {
            String country = row.length > 0 && row[0] != null ? row[0]!.value.toString() : '';
            String state = row.length > 1 && row[1] != null ? row[1]!.value.toString() : '';
            String district = row.length > 2 && row[2] != null ? row[2]!.value.toString() : '';
            String city = row.length > 3 && row[3] != null ? row[3]!.value.toString() : '';

            if (country.isNotEmpty || state.isNotEmpty || district.isNotEmpty || city.isNotEmpty) {
              locations.add({
                'country': country,
                'state': state,
                'district': district,
                'city': city,
              });
            }
          }
        }
      }

      for (var location in locations) {
        String locationQuery = _buildLocationQuery(location);
        if (locationQuery.isNotEmpty) {
          final apiKey = '192a36f37ec41b9e9902e8c62755c32f';
          final weatherUrl = 'https://api.openweathermap.org/data/2.5/weather?q=$locationQuery&appid=$apiKey';
          final weatherResponse = await http.get(Uri.parse(weatherUrl));

          if (weatherResponse.statusCode == 200) {
            var weatherJson = json.decode(weatherResponse.body);
            setState(() {
              _weatherReports.add({
                'location': locationQuery,
                'description': weatherJson['weather'][0]['description'],
                'temperature': '${weatherJson['main']['temp']}°K',
                'humidity': '${weatherJson['main']['humidity']}%',
              });
            });
          } else {
            setState(() {
              _weatherReports.add({
                'location': locationQuery,
                'description': 'Failed to load weather data',
              });
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _weatherReports.add({
          'location': 'Error',
          'description': 'Error fetching weather data: $e',
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildLocationQuery(Map<String, String> location) {
    List<String> queries = [];
    if (location['city']!.isNotEmpty) {
      queries.add(location['city']!);
    }
    if (location['district']!.isNotEmpty) {
      queries.add(location['district']!);
    }
    if (location['state']!.isNotEmpty) {
      queries.add(location['state']!);
    }
    if (location['country']!.isNotEmpty) {
      queries.add(location['country']!);
    }
    return queries.join(',');
  }

  Widget _buildLayout(int layoutIndex) {
    switch (layoutIndex) {
      case 0:
        return _buildListViewLayout();
      case 1:
        return _buildGridViewLayout();
      case 2:
        return _buildCardLayout();
      case 3:
        return _buildTableLayout();
      case 4:
        return _buildStackedLayout();
      default:
        return _buildListViewLayout();
    }
  }

  Widget _buildListViewLayout() {
    return ListView.builder(
      itemCount: _weatherReports.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            SizedBox(height: 25,),
            Text("Listview Layout",style: TextStyle(fontSize: 15),),
            SizedBox(height: 25,),
            ListTile(
              title: Text('Location: ${_weatherReports[index]['location']}',style: TextStyle(fontSize: 20),),
              subtitle: Text('Weather: ${_weatherReports[index]['description']}\n'
                  'Temperature: ${_weatherReports[index]['temperature']}\n'
                  'Humidity: ${_weatherReports[index]['humidity']}'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridViewLayout() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:1,
        childAspectRatio: 1,
      ),
      itemCount: _weatherReports.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            SizedBox(height: 25,),
            Text("GridView Layout",style: TextStyle(fontSize: 15),),
            SizedBox(height: 25,),
            Card(
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location:     ${_weatherReports[index]['location']}',style: TextStyle(fontSize: 20),),
                    SizedBox(height: MediaQuery.of(context).size.height*0.03,),
                    Text('Weather: ${_weatherReports[index]['description']}',style: TextStyle(fontSize: 15),),
                    Text('Temperature: ${_weatherReports[index]['temperature']}',style: TextStyle(fontSize: 15),),
                    Text('Humidity: ${_weatherReports[index]['humidity']}',style: TextStyle(fontSize: 15),),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardLayout() {
    return ListView.builder(
      itemCount: _weatherReports.length,
      itemBuilder: (context, index) {
        return SizedBox(
          height: MediaQuery.of(context).size.height*0.3,
          child: Column(
            children: [
              SizedBox(height: 25,),
              Text("CARD Layout",style: TextStyle(fontSize: 15),),
              SizedBox(height: 25,),
              Card(
                color: Colors.grey[200],
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Location: ${_weatherReports[index]['location']}',style: TextStyle(fontSize: 20),),
                  subtitle: Text('Weather: ${_weatherReports[index]['description']}\n'
                      'Temperature: ${_weatherReports[index]['temperature']}\n'
                      'Humidity: ${_weatherReports[index]['humidity']}',style: TextStyle(fontSize: 15),),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableLayout() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          SizedBox(height: 25,),
          Text("Table Layout",style: TextStyle(fontSize: 15),),
          SizedBox(height: 25,),
          Divider(thickness: 2,),
          DataTable(
            columns: [
              DataColumn(label: Text('Location')),
              DataColumn(label: Text('Weather')),
              DataColumn(label: Text('Temperature')),
              DataColumn(label: Text('Humidity')),
            ],
            rows: _weatherReports.map((report) {
              return DataRow(cells: [
                DataCell(Text(report['location']!)),
                DataCell(Text(report['description']!)),
                DataCell(Text(report['temperature']!)),
                DataCell(Text(report['humidity']!)),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedLayout() {
    return ListView.builder(
      itemCount: _weatherReports.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            SizedBox(height: 25,),
            Text("Stackedlayout Layout",style: TextStyle(fontSize: 15),),
            SizedBox(height: 25,),
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location: ${_weatherReports[index]['location']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Weather: ${_weatherReports[index]['description']}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Temperature: ${_weatherReports[index]['temperature']}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Humidity: ${_weatherReports[index]['humidity']}',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Information'),
        backgroundColor: Colors.lightGreen[100],
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(child: _buildLayout(_currentLayoutIndex)),
          Padding(
            padding: const EdgeInsets.only(bottom: 200),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentLayoutIndex = (_currentLayoutIndex + 1) % 5;
                });
              },
              child: Text('Switch Layout',style: TextStyle(color: Colors.black),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen[100]),
            ),
          ),
        ],
      ),
    );
  }
}
