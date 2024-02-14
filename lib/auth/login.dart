import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:my_todo/home.dart';
import 'package:my_todo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginPage extends StatelessWidget {
  const loginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
                child: Center(
                    child: Column(
      children: [
        _Logo(),
        _FormContent(),
      ],
    )))));
  }
}

class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 60),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                spreadRadius: 10,
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_box_rounded,
                color: Colors.blue.shade600,
                size: 100,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            "My Todo",
            textAlign: TextAlign.center,
            style: GoogleFonts.mulish(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.2),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 1, left: 60, right: 60, bottom: 50),
            child: Text(
              "Login first to organize your best moment to do",
              textAlign: TextAlign.center,
              style: GoogleFonts.mulish(
                  fontSize: 15, color: Colors.black54, height: 1.2),
            )),
      ],
    );
  }
}

class _FormContent extends StatefulWidget {
  const _FormContent({Key? key}) : super(key: key);

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {
  bool _isPasswordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan Username Anda';
                }

                return null;
              },
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Masukkan Username Anda',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(15.0),
                  ),
                ),
              ),
              autofocus: true,
            ),
            _gap(),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan Password Anda';
                }

                if (value.length < 5) {
                  return 'Password Harus Lebih Dari 6 Karakter';
                }

                return null;
              },
              obscureText: !_isPasswordVisible,
              controller: passwordController,
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan Password Anda',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(15.0),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )),
            ),
            SizedBox(height: 40),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _login(context);
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
                "Login",
                style: GoogleFonts.mulish(
                    fontSize: 15,
                    color: Colors.blue.shade700,
                    height: 1.2,
                    fontWeight: FontWeight.bold),
              ),
            ),
            _gap(),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(450, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "Back",
                style: GoogleFonts.mulish(
                    fontSize: 15,
                    color: Colors.blue.shade700,
                    height: 1.2,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);

  Future _login(context) async {
    // Proses Login
    String url = "http://192.168.18.7/api_flutter/todo/public/api/login";
    final response = await http.post(Uri.parse(url), body: {
      "username": usernameController.text,
      "password": passwordController.text,
    });

    Map data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // Simpan token ke shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('user_id', data['user']['id']);
      prefs.setString('token', data['token']);
      prefs.setString('nama', data['user']['name']);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => homePage()),
      );
    } else if (response.statusCode == 401) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Login Gagal!",
              style: GoogleFonts.mulish(
                fontSize: 18,
                height: 1.2,
                fontWeight: FontWeight.bold,
              )),
          content: Text(data["message"],
              style: GoogleFonts.mulish(
                  fontSize: 16, height: 1.2, fontWeight: FontWeight.bold)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(170, 57.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "Mengerti",
                style: GoogleFonts.mulish(
                    fontSize: 15,
                    color: Colors.blue.shade700,
                    height: 1.2,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }
}
