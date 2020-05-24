import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:todoist/app/home/home_page.dart';
import 'package:todoist/app/lists/display_list_of_user.dart';

class AddListPage extends StatefulWidget {
  @override
  _AddListPageState createState() => _AddListPageState();
}

class _AddListPageState extends State<AddListPage> {
  String _task;
  DateTime _date;
  final _formKey = GlobalKey<FormState>();

  bool checkStatusOfForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _addTask() async {
    if (checkStatusOfForm()) {
      SharedPreferences sharedPreferences;
      print("Task added");
      print('task: $_task, datetime: $_date');
      String validateUrl =
          "https://todoistapi.000webhostapp.com/validate_token.php";
      sharedPreferences = await SharedPreferences.getInstance();
      String jwtToken = sharedPreferences.getString("token");
      print("$jwtToken");
      Map data = {"jwt": jwtToken};
      var jsonDataEncode = jsonEncode(data);
      var response =
          await http.post(Uri.encodeFull(validateUrl), body: jsonDataEncode);
      if (response.statusCode == 200) {
        var userDataDecoded = jsonDecode(response.body);
        Map userData = userDataDecoded["data"];
        String uid = userData["id"];
        String createTaskUrl =
            "https://todoistapi.000webhostapp.com/create_task.php";
        Map taskData = {"task": _task, "date_time": "$_date", "uid": uid};
        var taskJsonData = jsonEncode(taskData);
        var taskResponse =
            await http.post(Uri.encodeFull(createTaskUrl), body: taskJsonData);
        if (taskResponse.statusCode == 200) {
          print(taskResponse.body);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          // image: DecorationImage(
          //   image: NetworkImage(
          //     'https://media.istockphoto.com/photos/todo-list-personal-planner-on-turquoise-office-table-picture-id925734296?k=6&m=925734296&s=612x612&w=0&h=_VB2egSpS_1RFYSknOl8v19wqT7dMbeRv8duolALfDc=',
          //   ),
          //   fit: BoxFit.cover,
          //   colorFilter: ColorFilter.mode(
          //       Colors.black.withOpacity(0.2), BlendMode.dstATop),
          // ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Add ',
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      Text(
                        'Task',
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/add_task_logo.jpg'),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  _taskInputField(),
                  SizedBox(height: 10.0),
                  _dateTimeInputField(),
                  SizedBox(height: 20.0),
                  SizedBox(
                    height: 50.0,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          side: BorderSide(color: Colors.white)),
                      padding: EdgeInsets.only(left: 50, right: 50),
                      textColor: Colors.white,
                      child: Text('Add Task'),
                      onPressed: _addTask,
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

  Widget _taskInputField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      onSaved: (value) => _task = value,
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
          labelText: 'Task'),
    );
  }

  Widget _dateTimeInputField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            side: BorderSide(color: Colors.white)),
        padding: EdgeInsets.only(left: 50, right: 50),
        textColor: Colors.white,
        child: _date == null
            ? Text(
                'Set date and time',
                textAlign: TextAlign.left,
              )
            : Text(
                '${DateFormat("yyyy-MM-dd, hh:mm:ss").format(_date)}',
                textAlign: TextAlign.left,
              ),
        onPressed: () {
          DatePicker.showDateTimePicker(
            context,
            showTitleActions: true,
            minTime: DateTime(2018, 3, 5),
            maxTime: DateTime(2100, 3, 5),
            onChanged: (date) {
              print('changed $date');
            },
            onConfirm: (date) {
              setState(() {
                _date = date;
              });
            },
            currentTime: DateTime.now(),
            locale: LocaleType.en,
          );
        },
      ),
    );
  }
}
