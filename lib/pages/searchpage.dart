import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_food/pages/showItems.dart';
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
    List<DocumentSnapshot> allResults = [];
    for (var doc in data.docs) {
      var itemsData = await FirebaseFirestore.instance
          .collection('categories')
          .doc(doc.id)
          .collection('items')
          .get();
      for (var item in itemsData.docs) {
        allResults.add(item);
      }
    }
    setState(() {
      _allResults = allResults;
    });
    searchResultList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getClientStream();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CupertinoSearchTextField(
          controller: _searchController,
          placeholder: 'Search...',
          onSubmitted: (_) {},
        ),
      ),
      body: Expanded(
        child: ListView.builder(
          itemCount: _resultList.length,
          itemBuilder: (context, index) {
            if (index == 0 && _resultList.isEmpty) {
              return Center(
                child: Text(
                  'No results found',
                  style: TextStyle(fontSize: 24),
                ),
              );
            }
            return ListTile(
              leading: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.black12,
                child: Icon(
                  Icons.search,
                  color: Colors.black87,
                ),
              ),
              title: Text(_resultList[index]['name']),
              onTap: () {
                _handleCategoryTap(_resultList[index]['name']);
              },
            );
          },
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
