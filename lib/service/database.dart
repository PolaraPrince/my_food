import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      await categoryDoc.update({'uid': categoryUid});
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

  Future addFoodItem(Map<String, dynamic> foodItem, String categoryName) async {
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .get();
    if (categorySnapshot.docs.isNotEmpty) {
      String categoryUid = categorySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryUid)
          .collection('items')
          .add(foodItem);
    } else {}
  }

  Future<Stream<QuerySnapshot>> getFoodItems(String category) async {
    return FirebaseFirestore.instance.collection(category).snapshots();
  }

  Future<Stream<QuerySnapshot>> getFoodItem(String name) async {
    return await FirebaseFirestore.instance.collection(name).snapshots();
  }

  Future<List<String>> searchCategories(String query) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: ('${query}z').toLowerCase())
        .get();
    return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<List<String>> searchItems(String query) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cart')
        .where('itemName', isGreaterThanOrEqualTo: query)
        .where('itemName', isLessThan: ('${query}z'))
        .get();
    return querySnapshot.docs.map((doc) => doc['itemName'] as String).toList();
  }
  
}
