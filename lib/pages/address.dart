import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAddressPage extends StatefulWidget {
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name,_houseno, _apartment,_landmark, _city, _zipCode;
  bool _isDefault = false;
  late String _selectedLocation = ""; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Address"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: "Name"),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter an address";
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "House No."),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter an address";
                }
                return null;
              },
              onSaved: (value) => _houseno = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Apartment, suite, etc."),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter an address";
                }
                return null;
              },
              onSaved: (value) => _apartment = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Landmark"),
              onSaved: (value) => _landmark = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "City"),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter a city";
                }
                return null;
              },
              onSaved: (value) => _city = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Zip/postal code"),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter a zip/postal code";
                }
                return null;
              },
              onSaved: (value) => _zipCode = value!,
            ),
            Column(
              children: [
                // Radio buttons for selecting location
                ListTile(
                  title: Text("Home"),
                  leading: Radio(
                    value: "Home",
                    groupValue: _selectedLocation,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedLocation = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text("Office"),
                  leading: Radio(
                    value: "Office",
                    groupValue: _selectedLocation,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedLocation = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text("Other"),
                  leading: Radio(
                    value: "Other",
                    groupValue: _selectedLocation,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedLocation = value!;
                      });
                    },
                  ),
                ),
                CheckboxListTile(
                  title: Text("Set as default address"),
                  value: _isDefault,
                  onChanged: (bool? value) {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      setState(() {
                        _isDefault = value!;
                        if (_isDefault) {
                          // Check if default address already exists
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(user.uid)
                              .collection("addresses")
                              .where("isDefault", isEqualTo: true)
                              .get()
                              .then((querySnapshot) {
                            if (querySnapshot.docs.isNotEmpty) {
                              // Default address already exists, show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Default address already exists"),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              setState(() {
                                _isDefault = false;
                              });
                            }
                          });
                        }
                      });
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(user.uid)
                            .collection("addresses")
                            .add({
                          "name": _name,
                          "houseno":_houseno,
                          "apartment": _apartment,
                          "landmark":_landmark,
                          "city": _city,
                          "zipCode": _zipCode,
                          "location": _selectedLocation, // Store selected location
                          "isDefault": _isDefault,
                        }).then((value) {
                          Navigator.pop(context);
                        }).catchError((error) {
                          print("Failed to add address: $error");
                        });
                      }
                    }
                  },
                  child: Text("Submit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
