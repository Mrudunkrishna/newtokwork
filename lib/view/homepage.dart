import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterprjct/view/excel.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightGreen[100],
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width*0.5,
            height: MediaQuery.of(context).size.height*0.05,
            child: ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExcelUploadPage(),));
              },
              child: Text('  Upload excel file ',style: TextStyle(color: Colors.black),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[100]),
            ),
          ),
        ],
      ),
      body:
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('countries').snapshots(),
        builder: (context, countrySnapshot) {
          if (countrySnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!countrySnapshot.hasData || countrySnapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data found'));
          }

          return ListView.builder(
            itemCount: countrySnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var countryDoc = countrySnapshot.data!.docs[index];
              var countryName = countryDoc['name'];

              return Column(
                children: [
                  SizedBox(height: 35,),
                  ExpansionTile(
                    title: Text(countryName),
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: countryDoc.reference.collection('states').snapshots(),
                        builder: (context, stateSnapshot) {
                          if (!stateSnapshot.hasData || stateSnapshot.data!.docs.isEmpty) {
                            return ListTile(title: Text('No states found'));
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 85),
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.8,
                              child: Card(
                                color: Colors.lightGreen[100],
                                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: stateSnapshot.data!.docs.map((stateDoc) {
                                      var stateName = stateDoc['name'];
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Text('State: $stateName', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          StreamBuilder<QuerySnapshot>(
                                            stream: stateDoc.reference.collection('districts').snapshots(),
                                            builder: (context, districtSnapshot) {
                                              if (!districtSnapshot.hasData || districtSnapshot.data!.docs.isEmpty) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                  child: Text('No districts found'),
                                                );
                                              }

                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: districtSnapshot.data!.docs.map((districtDoc) {
                                                  var districtName = districtDoc['name'];
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
                                                        child: Text('District: $districtName', style: TextStyle(fontWeight: FontWeight.w500)),
                                                      ),
                                                      StreamBuilder<QuerySnapshot>(
                                                        stream: districtDoc.reference.collection('cities').snapshots(),
                                                        builder: (context, citySnapshot) {
                                                          if (!citySnapshot.hasData || citySnapshot.data!.docs.isEmpty) {
                                                            return Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                                              child: Text('No cities found'),
                                                            );
                                                          }

                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: citySnapshot.data!.docs.map((cityDoc) {
                                                              var cityName = cityDoc['name'];
                                                              return Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 32.0),
                                                                child: Text('City: $cityName'),
                                                              );
                                                            }).toList(),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
