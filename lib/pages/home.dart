import 'dart:math';

import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_food/pages/addcart.dart';
import 'package:my_food/pages/details.dart';
import 'package:my_food/pages/showItems.dart';
import 'package:my_food/pages/searchpage.dart';
import 'package:my_food/service/database.dart';
import 'package:my_food/widget/widget_support.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  String name = '';
  User? user = FirebaseAuth.instance.currentUser;
  Future<List<String>> getCategories() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    List<String> categories =
        querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    return categories;
  }

  late Future<List<Map<String, dynamic>>> bannersFuture;
  @override
  void initState() {
    super.initState();
    categoriesFuture = DatabaseMethods().getCategories();
    bannersFuture = FirebaseFirestore.instance
        .collection('banners')
        .get()
        .then((QuerySnapshot querySnapshot) {
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          setState(() {
            name = documentSnapshot['name'];
            isLoading = false;
          });
        }
      });
    }
  }

  late Future<List<String>> categoriesFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: EdgeInsets.only(top: 55.0, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hello ${name!},",
                style: AppWidget.headlineTextFeildStyle(),
              ),
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CartPage()));
                    },
                    child:
                        Icon(Icons.shopping_bag_outlined, color: Colors.white)),
              ),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 5.0, left: 15, right: 15),
            child: Text('Shop smart, save more today!',
                style: AppWidget.lightTextFeildStyle())),
        Container(
            margin: EdgeInsets.only(top: 5.0, left: 15, right: 15),
            child: Text('Fresh picks, delivered fast!',
                style: AppWidget.lightTextFeildStyle())),
        SizedBox(height: 8),
        Container(
          margin: EdgeInsets.only(left: 15, right: 15),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.search,
                    size: 18,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Search...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Text(
            'Categories',
            style: AppWidget.semiBoldTextFeildStyle(),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FutureBuilder<List<String>>(
            future: getCategories(),
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                    right: 15.0,
                  ),
                  child: Row(
                    children: snapshot.data!.map((category) {
                      return FutureBuilder<String?>(
                        future: DatabaseMethods().getCategoryImageUrl(category),
                        builder: (BuildContext context,
                            AsyncSnapshot<String?> imageSnapshot) {
                          if (imageSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (imageSnapshot.hasError) {
                            return Text('Error: ${imageSnapshot.error}');
                          } else {
                            final imageUrl = imageSnapshot.data;
                            return Container(
                              margin: EdgeInsets.only(right: 18.0),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _handleCategoryTap(category);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 35,
                                      child: CachedNetworkImage(
                                          imageUrl: imageUrl!,
                                          placeholder: (context, url) =>
                                              Center()),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    category,
                                    style: TextStyle(
                                        color: Color(0xff6D3805),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double containerWidth = constraints.maxWidth;
              double containerHeight = containerWidth / 2.5;

              return Container(
                width: containerWidth,
                height: containerHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: bannersFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return AnotherCarousel(
                            images: snapshot.data!
                                .map((banner) => CachedNetworkImage(
                                      imageUrl: banner['image'],
                                      fit: BoxFit.fill,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ))
                                .toList(),
                            autoplayDuration: Duration(seconds: 20),
                            dotSize: 4,
                            dotSpacing: 15.0,
                            indicatorBgPadding: 2,
                            dotBgColor: Colors.transparent,
                            dotColor: Colors.black,
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 10,
          ),
          child: Text(
            'Popular Deals',
            style: AppWidget.semiBoldTextFeildStyle(),
          ),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: getPopularItems(),
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Container(
                padding: EdgeInsets.only(left: 15),
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    final itemName = item['name'];
                    final itemImage = item['image'];
                    final itemPrice = item['price'];
                    final itemUid = item['uid'];

                    return Container(
                      margin: EdgeInsets.only(
                          right: 10, top: 15, bottom: 5, left: 10),
                      height: 190,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 187, 187, 187),
                            offset: Offset(0.0, 1.0),
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _handleItemTap(itemUid);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: itemImage,
                                  width: 150,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            itemName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '\₹${itemPrice.toString()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {
                              _handleItemTap(itemUid);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Add to Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
        SizedBox(
          height: 20.0,
        )
      ]),
    ));
  }

  void _handleCategoryTap(String categoryName) {
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

  void _handleItemTap(String itemId) {
    final itemDoc = FirebaseFirestore.instance.collection('items').doc(itemId);
    itemDoc.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(
              item: documentSnapshot,
            ),
          ),
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getPopularItems() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('PopularDeals').get();

    List<Map<String, dynamic>> popularItems = [];

    for (var doc in querySnapshot.docs) {
      final itemUid = doc['iteamuid'];
      final itemDoc = await FirebaseFirestore.instance
          .collection('items')
          .doc(itemUid)
          .get();
      if (itemDoc.exists) {
        popularItems.add({
          'name': itemDoc['name'],
          'image': itemDoc['image'],
          'price': itemDoc['price'],
          'uid': itemUid,
        });
      }
    }

    return popularItems;
  }
}
