import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_todo/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'page/create.dart';
import 'page/update.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

String token = '';

class _homePageState extends State<homePage> {
  bool _isMenuOpen = false;
  List<dynamic> _todoList = [];

  void initState() {
    super.initState();
    _getUser();
    _fetchToDoList();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  Future _fetchToDoList() async {
    final prefs = await SharedPreferences.getInstance();
    var userid = prefs.getInt('user_id');
    String url = "http://192.168.18.7/api_flutter/todo/public/api/task/${userid}";
    var token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    Map responseData = json.decode(response.body);

    if (response.statusCode == 201) {
      if (responseData.containsKey('data')) {
        List<dynamic> todoList = responseData['data'];
        if (todoList.isNotEmpty) {
          setState(() {
            _todoList = todoList;
          });
        }
      }
    } else {
      Fluttertoast.showToast(
          msg: "Session Expired Please Re Login",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);

      prefs.setInt('user_id', 0);
      prefs.setString('token', "");
      prefs.setString('nama', "");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => loginPage()),
      );
    }
  }

  Future _deleteTodo(Map todo) async {
    String url =
        "http://192.168.18.7/api_flutter/todo/public/api/task/${todo['id']}";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 201) {
      _fetchToDoList();
      Fluttertoast.showToast(
          msg: "Success Delete",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (response.statusCode == 401) {
      Fluttertoast.showToast(
          msg: "Session Expired Please Re Login",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      prefs.setInt('user_id', 0);
      prefs.setString('token', "");
      prefs.setString('nama', "");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => loginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: _isMenuOpen
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: _toggleMenu,
                )
              : IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: _toggleMenu,
                ),
          title: Padding(
              padding: EdgeInsets.only(left: 90, top: 5),
              child: Text(
                "My Todo",
                style: GoogleFonts.mulish(
                    fontSize: 23,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              )),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => createTodo()),
            ).then((value) => _fetchToDoList());
          },
          backgroundColor: Colors.blue,
          elevation: 4,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 35,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              CardNotification(),
              Row(
                children: [
                  CustomTitle(
                      text: "Remaining Tasks", fontWeight: FontWeight.normal),
                  CustomTitle(
                      text: "(${_todoList.length})",
                      fontWeight: FontWeight.bold)
                ],
              ),
              if (_todoList.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                      child: Text("No tasks to show",
                          style: GoogleFonts.mulish(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal))),
                )
              else
                Expanded(
                    child: ListView.builder(
                  itemCount: _todoList.length,
                  itemBuilder: (context, index) {
                    Map item = _todoList[index];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Column(
                                children: [
                                  CustomTitle(
                                      text: "Select an Action For Todo :",
                                      fontWeight: FontWeight.normal),
                                  CustomTitle(
                                      text: "${item['title']}",
                                      fontWeight: FontWeight.bold),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return updatePage(
                                          todo: item,
                                        );
                                      }),
                                    );
                                  },
                                  child: Text('Edit',
                                      style: GoogleFonts.mulish(
                                          fontSize: 18,
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.normal)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteTodo(item).then((value) {
                                      _fetchToDoList();
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Delete',
                                      style: GoogleFonts.mulish(
                                          fontSize: 18,
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.normal)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: CustomCard(
                        iconData: Icons.check_circle_rounded,
                        text: item['title'],
                        time: item['formatted_due_date'],
                      ),
                    );
                  },
                )),
            ],
          ),
        ));
  }
}

class CustomTitle extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;

  CustomTitle({required this.text, required this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          text,
          style: GoogleFonts.mulish(
              fontSize: 18, color: Colors.black, fontWeight: fontWeight),
        ),
      ),
    );
  }
}

class CardNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        color: Colors.green.shade50,
        elevation: 0.2,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.only(left: 20, top: 0, bottom: 0, right: 20),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.check_circle,
                size: 30,
                color: Colors.green,
              ),
              Expanded(
                  child: Padding(
                padding:
                    EdgeInsets.only(top: 25, bottom: 25, left: 25, right: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Complete Flutter UI App challenge and upload it on Github',
                      style: GoogleFonts.mulish(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              )),
              Text(
                "1h 25m",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final IconData iconData;
  final String text;
  final String time;

  CustomCard({required this.iconData, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.only(left: 20, top: 0, bottom: 0, right: 20),
        child: Row(
          children: <Widget>[
            Icon(
              iconData,
              size: 30,
              color: Colors.blue,
            ),
            Expanded(
                child: Padding(
              padding:
                  EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    text,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )),
            Text(
              time,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _getUser() async {
  final prefs = await SharedPreferences.getInstance();

  token = prefs.getString('token')!;
}
