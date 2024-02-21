import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_food/pages/details.dart';
import 'package:my_food/pages/searchpage.dart';
import 'package:my_food/service/database.dart';
import 'package:my_food/widget/widget_support.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _allResults = [];
  List _resultList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();

    categoriesFuture = DatabaseMethods().getCategories();
  }

  _onSearchChanged() {
    searchResultList();
  }

  searchResultList() {
    var showResults = [];
    if (_searchController.text != "") {
      for (var clientSnapShot in _allResults) {
        var name = clientSnapShot["name"].toString().toLowerCase();
        if (name.contains(_searchController.text.toLowerCase())) {
          showResults.add(clientSnapShot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultList = showResults;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  late Future<List<String>> categoriesFuture;
  String _selectedLocation = 'Your Location';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xff9AD0C2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 55.0, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hello Prince,",
                    style: AppWidget.boldTextFeildStyle(),
                  ),
                  Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      borderRadius: BorderRadius.circular(10),
                      underline: Container(),
                      value: _selectedLocation,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLocation = newValue!;
                        });
                      },
                      items: <String>[
                        'Your Location',
                        'Palledium mall, near shola overbridge,',
                        'Add New Location',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: SizedBox(
                            width: 200,
                            child: Text(
                              value,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 8),
                    CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Search...',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 150.0,
                      width: 150.0,
                      child: ListView.builder(
                        itemCount: _resultList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _handleCategoryTap(_resultList[index]['name']);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _resultList[index]['name'],
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: categoriesFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 20.0,
                        runSpacing: 20.0,
                        children: snapshot.data!.map((category) {
                          return GestureDetector(
                            onTap: () {
                              _handleCategoryTap(category);
                            },
                            child: Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(18.0),
                              child: Container(
                                height: 150.0,
                                width: 110.0,
                                decoration: BoxDecoration(
                                  color: Color(0xffF1FADA),
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
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
            builder: (context) => DetailsPage(
              uid: uid,
              categoryName: categoryName,
              location: _selectedLocation,
            ),
          ),
        );
      }
    }).catchError((error) {
      print("Error: $error");
    });
  }
}
