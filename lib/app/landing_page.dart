import 'package:flutter/material.dart';
import 'package:todoist/app/signin/login_page.dart';
import 'package:todoist/app/signin/sign_up_page.dart';

enum EmailSignInFormType { login, signup }

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  EmailSignInFormType _formType = EmailSignInFormType.login;
  void _toggleFormType() {
    setState(() {
      _formType = _formType == EmailSignInFormType.login
          ? EmailSignInFormType.signup
          : EmailSignInFormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_formType == EmailSignInFormType.login) {
      return LoginPage(toggleFormType: _toggleFormType);
    }
    return SignUpPage(
      toggleFormType: _toggleFormType,
    );
  }
}
