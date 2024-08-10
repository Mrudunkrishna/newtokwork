import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutterprjct/control/api.dart';



class ExcelUploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<ExcelUploadPage> {
  bool _isUploading = false;

  Future<void> uploadFile() async {
    setState(() {
      _isUploading = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      try {
        final storageRef = FirebaseStorage.instance.ref().child('uploads/${result.files.single.name}');
        final uploadTask = storageRef.putFile(file);

        await uploadTask;
        print('File Uploaded');

        // Navigate to WeatherPage after successful upload
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherPage(fileName: result.files.single.name),
          ),
        );
      } catch (e) {
        print('Error uploading file: $e');
      }
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Excel File'),
      backgroundColor: Colors.lightGreen[100],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.2),
          Text("Upload n Excel file here",style: TextStyle(fontSize: 20),),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isUploading ? null : uploadFile,
              child: _isUploading ? CircularProgressIndicator() : Text('Upload Excel File',
                style:TextStyle(
                    color: Colors.black
                ) ,),
            ),
          ),
        ],
      ),
    );
  }
}