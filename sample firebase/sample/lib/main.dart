import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Firestore Example')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _addDataToFirestore();
                },
                child: Text('Add Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  void _addDataToFirestore() {
    FirebaseFirestore.instance.collection('user').add(
        {'name': _nameController.text, 'age': int.parse(_ageController.text)});
  }
}
