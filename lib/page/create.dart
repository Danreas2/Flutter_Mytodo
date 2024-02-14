import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:my_todo/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class createTodo extends StatefulWidget {
  const createTodo({super.key});

  @override
  State<createTodo> createState() => _createTodoState();
}

String token = '';

class _createTodoState extends State<createTodo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime? _dueDate;
  int _completed = 0;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future _saveTodo() async {
    String url = "http://192.168.18.7/api_flutter/todo/public/api/task";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({
        'user_id': prefs.getInt('user_id'),
        'title': _title,
        'description': _description,
        'due_date': _dueDate!.toString(),
        'completed': _completed.toString(),
      }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 201) {
      Fluttertoast.showToast(
          msg: "Success Add Todo",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.of(context).pop();
    } else if (response.statusCode == 01) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Create New Todo",
            style: GoogleFonts.mulish(
                fontSize: 23, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        prefixIcon: const Icon(Icons.short_text),
                        border: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _title = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: const Icon(Icons.textsms_outlined),
                        border: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _description = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        prefixIcon: const Icon(Icons.date_range_outlined),
                        border: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(15.0),
                          ),
                        ),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != _dueDate) {
                          setState(() {
                            _dueDate = picked;
                          });
                        }
                      },
                      readOnly: true,
                      controller: TextEditingController(
                        text: _dueDate != null
                            ? DateFormat('yyyy-MM-dd').format(_dueDate!)
                            : '',
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                          labelText: 'Completed',
                          prefixIcon: (_completed == 1)
                              ? Icon(Icons.check_rounded)
                              : Icon(Icons.close),
                          border: const OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(15.0),
                            ),
                          )),
                      value: _completed,
                      items: [
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Not Completed'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Completed'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _completed = value!;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _saveTodo();
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        minimumSize: Size(450, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "Submit",
                        style: GoogleFonts.mulish(
                            fontSize: 18,
                            color: Colors.blue.shade700,
                            height: 1.2,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

Future<void> _getUser() async {
  final prefs = await SharedPreferences.getInstance();

  token = prefs.getString('token')!;
}
