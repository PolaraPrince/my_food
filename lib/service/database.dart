import 'dart:ffi';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  UpdateUserwallet(String id, String amount) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({'wallet': amount});
  }

  Future<void> addCategory(String categoryName, BuildContext context) async {
    final categoriesRef = FirebaseFirestore.instance.collection('categories');
    QuerySnapshot categorySnapshot =
        await categoriesRef.where('name', isEqualTo: categoryName).get();
    if (categorySnapshot.docs.isEmpty) {
      final categoryDoc = await categoriesRef.add({'name': categoryName});
      final categoryUid = categoryDoc.id;
      await categoryDoc.update({'categoryUid': categoryUid});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter valid category name')),
      );
    }
  }

  Future<List<String>> getCategories() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    List<String> categories =
        querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    return categories;
  }

  Future<String> getCategoryImageUrl(String categoryName) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      final Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      return data['image'] as String;
    }
    return '';
  }

 Future<String> addFoodItem(Map<String, dynamic> foodItem, String categoryName,
      {Uint8List? file}) async {
    final categorySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .get();

    if (categorySnapshot.docs.isNotEmpty) {
      final categoryUid = categorySnapshot.docs.first.id;
      foodItem['categoryId'] = categoryUid;

      if (file != null) {
        final imageURL = await compute(_uploadImage, {
          'storageReference': FirebaseStorage.instance
              .ref()
              .child('food_images/${DateTime.now().millisecondsSinceEpoch}'),
          'file': file,
        });
        foodItem['imageURL'] = imageURL;
      }

      await FirebaseFirestore.instance.collection('items').add(foodItem);

      return 'success';
    } else {
      return 'The category $categoryName does not exist';
    }
  }

  Future<String> _uploadImage(Map<String, dynamic> data) async {
    final Reference storageReference = data['storageReference'];
    final Uint8List file = data['file'];

    final UploadTask uploadTask = storageReference.putData(file);
    final String imageURL = await (await uploadTask).ref.getDownloadURL();

    return imageURL;
  }

  Future<Stream<QuerySnapshot>> getFoodItems(String category) async {
    return FirebaseFirestore.instance.collection(category).snapshots();
  }

  Future<Stream<QuerySnapshot>> getFoodItem(String name) async {
    return FirebaseFirestore.instance.collection(name).snapshots();
  }
}
