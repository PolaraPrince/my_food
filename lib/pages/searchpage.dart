import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_food/pages/details.dart';
import 'package:my_food/service/database.dart';
import 'package:my_food/widget/widget_support.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List _allResults = [];
  List _resultList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  _onSearchChanged() {
    print(_searchController.text);
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

  getClientStream() async {
    var data = await FirebaseFirestore.instance
        .collection("categories")
        .orderBy('name')
        .get();

    setState(() {
      _allResults = data.docs;
    });
    searchResultList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void didChangeDependencies() {
    getClientStream();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff9AD0C2),
        title: CupertinoSearchTextField(
          controller: _searchController,
          placeholder: 'Search...',
          onSubmitted: (_) {},
        ),
      ),
      body: Container(
        color: Color(0xffF1FADA),
        child: Expanded(
          child: ListView.builder(
            itemCount: _resultList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_resultList[index]['name']),
                onTap: () {
                  _handleCategoryTap(_resultList[index]['name']);
                },
              );
            },
          ),
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
              location: 'Your Location',
            ),
          ),
        );
      }
    }).catchError((error) {
      print("Error: $error");
    });
  }
}
