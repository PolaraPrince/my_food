import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_food/pages/showItems.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final String imageUrl;

  CategoryCard({required this.categoryName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // Pass the context here
    return GestureDetector(
      onTap: () {
        _handleCategoryTap(context, categoryName); // Pass the context here
      },
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(18.0),
        child: Stack(
          children: [
            Container(
              height: 120.0,
              width: 90.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18.0),
                    bottomRight: Radius.circular(18.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(
                          categoryName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCategoryTap(BuildContext context, String categoryName) {
    // Add the context parameter here
    FirebaseFirestore.instance
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        String uid = querySnapshot.docs.first.id;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowItems(
              uid: uid,
              categoryName: categoryName,
            ),
          ),
        );
      }
    }).catchError((error) {
      print("Error: $error");
    });
  }
}
