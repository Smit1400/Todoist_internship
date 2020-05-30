import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoist/app/home/home_page.dart';
import 'package:todoist/app/lists/display_list_of_user.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({@required this.toggleFormType});
  final Function toggleFormType;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  String _username;

  String _email;

  String _password;

  bool _checkFormStatus() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _submit() async {
    if (_checkFormStatus()) {
      print("username: $_username, email: $_email, password: $_password");
      String url = 'https://todoistapi.000webhostapp.com/create_user.php';
      Map<String, String> data = {
        "username": _username,
        "image": "imgdfdfdf",
        "email": _email,
        "password": _password,
      };
      var jsonData = jsonEncode(data);
      var response = await http.post(Uri.encodeFull(url), body: jsonData);
      if (response.statusCode == 200) {
        print("response1 = ${response.body}");
        String loginUrl = "https://todoistapi.000webhostapp.com/login.php";
        Map<String, String> loginData = {
          "email": _email,
          "password": _password
        };
        var loginJsonData = jsonEncode(loginData);
        var loginResponse =
            await http.post(Uri.encodeFull(loginUrl), body: loginJsonData);
        if (loginResponse.statusCode == 200) {
          var finalData =
              jsonDecode(loginResponse.body.toString().substring(0));
          print(finalData["jwt"]);
          SharedPreferences sharedPreference =
              await SharedPreferences.getInstance();
          setState(() {
            sharedPreference.setString("token", finalData["jwt"]);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false);
          });
        }
      } else {
        print("response bad = ${response.body}");
      }
    } else {
      print("Error check your program!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: NetworkImage(
              'https://coloredbrain.com/wp-content/uploads/2016/07/login-background.jpg',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), BlendMode.dstATop),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 150,
                    width: 150,
                    child: Image.network(
                        'https://i0.wp.com/codecollege.co.za/wp-content/uploads/2016/12/kisspng-dart-programming-language-flutter-object-oriented-flutter-logo-5b454ed3d65b91.767530171531268819878.png?fit=550%2C424&ssl=1'),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 50),
                    child: Text(
                      'Todoist',
                      style: TextStyle(fontSize: 35, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _usernameInputField(),
                  SizedBox(height: 10.0),
                  _emailInputField(),
                  SizedBox(height: 10.0),
                  _passwordInputField(),
                  SizedBox(height: 10.0),
                  SizedBox(
                    height: 50.0,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          side: BorderSide(color: Colors.white)),
                      padding: EdgeInsets.only(left: 50, right: 50),
                      textColor: Colors.white,
                      child: Text('Create Account'),
                      onPressed: _submit,
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      // side: BorderSide(color: Colors.white)),
                      padding: EdgeInsets.only(left: 50, right: 50),
                      textColor: Colors.white,
                      child: Text('Already have an Account? Login'),
                      onPressed: widget.toggleFormType,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _usernameInputField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      onSaved: (value) => _username = value,
      textInputAction: TextInputAction.none,
      decoration: InputDecoration(
          hasFloatingPlaceholder: true,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          labelStyle: TextStyle(color: Colors.white),
          labelText: 'Username'),
    );
  }

  Widget _emailInputField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      onSaved: (value) => _email = value,
      textInputAction: TextInputAction.none,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          hasFloatingPlaceholder: true,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          // hintText: 'Enter your product title',
          labelStyle: TextStyle(color: Colors.white),
          labelText: 'Email Address'),
    );
  }

  Widget _passwordInputField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      onSaved: (value) => _password = value,
      textInputAction: TextInputAction.none,
      obscureText: true,
      decoration: InputDecoration(
          hasFloatingPlaceholder: true,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          labelStyle: TextStyle(color: Colors.white),
          labelText: 'Password'),
    );
  }
}
