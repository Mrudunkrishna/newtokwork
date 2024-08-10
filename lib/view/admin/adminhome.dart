import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class homeadmin extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<homeadmin> {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  void _uploadAllDetails() async {
    String countryName = _countryController.text.trim();
    String stateName = _stateController.text.trim();
    String districtName = _districtController.text.trim();
    String cityName = _cityController.text.trim();

    if (countryName.isNotEmpty &&
        stateName.isNotEmpty &&
        districtName.isNotEmpty &&
        cityName.isNotEmpty) {


      DocumentReference countryRef = await FirebaseFirestore.instance
          .collection('countries')
          .add({'name': countryName});


      DocumentReference stateRef = await countryRef.collection('states').add({
        'name': stateName,
      });


      DocumentReference districtRef =
      await stateRef.collection('districts').add({
        'name': districtName,
      });


      await districtRef.collection('cities').add({
        'name': cityName,
      });


      _countryController.clear();
      _stateController.clear();
      _districtController.clear();
      _cityController.clear();


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details uploaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightGreen[100],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.1,),
              TextField(
                controller: _countryController,
                decoration: InputDecoration(labelText: 'Country Name',
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.04,),
              TextField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'State Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.04,),
              TextField(
                controller: _districtController,
                decoration: InputDecoration(labelText: 'District Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.04,),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.04,),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.5,
                height: MediaQuery.of(context).size.height*0.05,
                child: ElevatedButton(
                  onPressed: _uploadAllDetails,
                  child: Text('Upload Details',style: TextStyle(color: Colors.black),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen[100]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
