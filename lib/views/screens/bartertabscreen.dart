import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mybarter/models/item.dart';
import 'package:mybarter/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:mybarter/ipconfig.dart';

//import 'itemcartscreen.dart';
import 'itemdetailscreen.dart';

//for item screen

class BarterTabScreen extends StatefulWidget {
  final User user;
  const BarterTabScreen({super.key, required this.user});

  @override
  State<BarterTabScreen> createState() => _BarterTabScreenState();
}

class _BarterTabScreenState extends State<BarterTabScreen> {
  String maintitle = "Barter";
  List<item> itemList = <item>[];
  late double screenHeight, screenWidth;
  late int axiscount = 2;
  int numofpage = 1, curpage = 1;
  int numberofresult = 0;
  var color;
  int cartqty = 0;

  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadbarteritems(1);
    print("Barter");
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      axiscount = 3;
    } else {
      axiscount = 2;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(maintitle,style: TextStyle(color: Colors.black,),),
        backgroundColor: Colors.amber[200],
        actions: [
          IconButton(
              onPressed: () {
                showsearchDialog();
              },
              icon: const Icon(Icons.search,color: Colors.black)),
          /*TextButton.icon(
            icon: const Icon(
              Icons.shopping_cart,
            ), // Your icon here
            label: Text(cartqty.toString()), // Your text here
            onPressed: () {
              if (cartqty > 0) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) => itemCartScreen(
                              user: widget.user,
                            )));
              }else{
                 ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("No item in cart")));
              }
            },
          )
          // Stack(
          //   alignment: Alignment.topRight,
          //   children: [
          //     IconButton(
          //         onPressed: () {},
          //         icon: const Icon(
          //           Icons.shopping_cart,
          //         )),
          //     Positioned(
          //         right: 30,
          //         bottom: 25,
          //         child: Text(
          //           cartqty.toString(),
          //           style: const TextStyle(color: Colors.red, fontSize: 18),
          //         )),
          //   ],
          // )
          // IconButton(
          //     onPressed: () {},
          //     icon: const Icon(
          //       Icons.shopping_cart,
          //     )),
          // Text(cartqty.toString()),*/
        ],
      ),
       backgroundColor: Colors.amber[50],
      body: itemList.isEmpty
          ? const Center(
              child: Text("No Data"),
            )
          : Column(children: [
              Container(
                height: 24,
                 color: Colors.amber[600],
                alignment: Alignment.center,
                child: Text(
                  "$numberofresult items Found",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              Expanded(
                  child: GridView.count(
                      crossAxisCount: axiscount,
                      children: List.generate(
                        itemList.length,
                        (index) {
                          return Card(
                            child: InkWell(
                              onTap: () async {
                                item useritem =
                                    item.fromJson(itemList[index].toJson());
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (content) =>
                                            ItemDetailsScreen(
                                              user: widget.user,
                                              useritem: useritem,
                                            )));
                                loadbarteritems(1);
                              },
                              child: Column(children: [
                                CachedNetworkImage(
                                  width: screenWidth,
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      "${MyConfig().SERVER}/mybarter/assets/items/${itemList[index].itemId}_image0.png",
                                  placeholder: (context, url) =>
                                      const LinearProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                                Text(
                                  itemList[index].itemName.toString(),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                Text(
                                  "RM ${double.parse(itemList[index].itemValue.toString()).toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "${itemList[index].itemQty} available",
                                  style: const TextStyle(fontSize: 14), 
                                ),
                              ]),
                            ),
                          );
                        },
                      ))),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: numofpage,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    //build the list for textbutton with scroll
                    if ((curpage - 1) == index) {
                      //set current page number active
                      color = Colors.amber[800];
                    } else {
                      color = Colors.black;
                    }
                    return TextButton(
                        onPressed: () {
                          curpage = index + 1;
                          loadbarteritems(index + 1);
                        },
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(color: color, fontSize: 18),
                        ));
                  },
                ),
              ),
            ]),
    );
  }

  void loadbarteritems(int pg) {
    http.post(Uri.parse("${MyConfig().SERVER}/mybarter/php/load_items.php"),
        body: {
          "cartuserid": widget.user.id,
          "pageno": pg.toString()
        }).then((response) {
      //print(response.body);
      log(response.body);
      itemList.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == "success") {
          numofpage = int.parse(jsondata['numofpage']); //get number of pages
          numberofresult = int.parse(jsondata['numberofresult']);
          print(numberofresult);
          var extractdata = jsondata['data'];
          cartqty = int.parse(jsondata['cartqty'].toString());
          print(cartqty);
          extractdata['items'].forEach((v) {
            itemList.add(item.fromJson(v));
          });
          print(itemList[0].itemName);
        }
        setState(() {});
      }
    });
  }

  void showsearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text(
            "Search?",
            style: TextStyle(),
          ),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: searchController,
                decoration: const InputDecoration(
                    labelText: 'Search',
                    labelStyle: TextStyle(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0),
                    ))),
            const SizedBox(
              height: 4,
            ),
            ElevatedButton(
                onPressed: () {
                  String search = searchController.text;
                  searchitem(search);
                  Navigator.of(context).pop();
                },
                child: const Text("Search"),style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.amber),))
          ]),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.amber),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void searchitem(String search) {
    http.post(Uri.parse("${MyConfig().SERVER}/mybarter/php/load_items.php"),
        body: {
          "cartuserid": widget.user.id,
          "search": search
        }).then((response) {
      //print(response.body);
      log(response.body);
      itemList.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == "success") {
          var extractdata = jsondata['data'];
          extractdata['items'].forEach((v) {
            itemList.add(item.fromJson(v));
          });
          print(itemList[0].itemName);
        }
        setState(() {});
      }
    });
  }
}