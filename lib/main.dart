import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_todo/auth/login.dart';
import 'package:my_todo/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyTodo());
}

String token = '';

class MyTodo extends StatelessWidget {
  const MyTodo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'My Todo',
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
            future: _saveUser(),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                );
              } else {
                return token == '' ? Landing() : homePage();
              }
            })));
  }
}

class Landing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Welcome My Todo",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              _logo(),
              _title(
                text: "Welcome to",
                size: 28,
                color: Colors.black87,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
              _title(
                  text: "My Todo",
                  size: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  height: 1.3),
              _text(
                text:
                    "My Todo helps you stay organized and perform your task much faster.",
              ),
              SizedBox(height: 40),
              _buttonDemo(text: "Try Demo", color: Colors.blue.shade50),
              _buttonNo(text: "No Thanks", color: Colors.white),
            ],
          ),
        ),
      )),
    );
  }
}

class _logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 150, bottom: 15),
        child: Container(
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
        ));
  }
}

class _title extends StatelessWidget {
  const _title(
      {super.key,
      required this.text,
      required this.size,
      required this.fontWeight,
      required this.height,
      required this.color});

  final String text;
  final double size, height;
  final FontWeight fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.mulish(
          fontSize: size, color: color, fontWeight: fontWeight, height: height),
    );
  }
}

class _text extends StatelessWidget {
  const _text({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 12, left: 50, right: 50, bottom: 15),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.mulish(
              fontSize: 15, color: Colors.black54, height: 1.2),
        ));
  }
}

class _buttonNo extends StatelessWidget {
  const _buttonNo({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 10),
        child: TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => loginPage(),
              ),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: color,
            minimumSize: Size(170, 57.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.mulish(
                fontSize: 15,
                color: Colors.blue.shade700,
                height: 1.2,
                fontWeight: FontWeight.bold),
          ),
        ));
  }
}

class _buttonDemo extends StatelessWidget {
  const _buttonDemo({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 10),
        child: TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => loginPage(),
              ),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: color,
            minimumSize: Size(170, 57.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.mulish(
                fontSize: 15,
                color: Colors.blue.shade700,
                height: 1.2,
                fontWeight: FontWeight.bold),
          ),
        ));
  }
}

Future<void> _saveUser() async {
  final prefs = await SharedPreferences.getInstance();

  token = prefs.getString('token') ?? '';
}
