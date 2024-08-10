import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterprjct/view/loginpage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text);

        await FirebaseFirestore.instance
            .collection('userdetail')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.lightGreen[100],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 60,),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15,),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15,),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15,),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.5,
                  height: MediaQuery.of(context).size.height*0.05,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: Text('Register',style: TextStyle(color: Colors.black),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen[100]),
                  ),
                ),
        
        
                SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.5,
                  height: MediaQuery.of(context).size.height*0.05,
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                    },
                    child: Text('  Login  ',style: TextStyle(color: Colors.black),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen[100]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
