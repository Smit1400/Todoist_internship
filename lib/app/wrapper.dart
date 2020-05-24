import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoist/app/home/home_page.dart';
import 'package:todoist/app/landing_page.dart';
import 'package:todoist/app/lists/display_list_of_user.dart';

enum whichPage { landind, display }

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  whichPage wch = whichPage.display;
  SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    checkStatusOfTheUser();
  }

  checkStatusOfTheUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      setState(() {
        wch = wch == whichPage.display ? whichPage.landind : whichPage.display;
      });
    } else {
      setState(() {
        wch = wch == whichPage.display ? whichPage.display : whichPage.landind;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (wch == whichPage.display) {
      return HomePage();
    } else {
      return LandingPage();
    }
    return Container();
  }
}
