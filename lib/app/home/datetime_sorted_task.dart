import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DateTimeWiseSortedList extends StatefulWidget {
  final Function totalTasks;
  DateTimeWiseSortedList({@required this.totalTasks});
  @override
  _DateTimeWiseSortedListState createState() => _DateTimeWiseSortedListState();
}

class _DateTimeWiseSortedListState extends State<DateTimeWiseSortedList> {
  List allTasks = [];
  @override
  void initState() {
    super.initState();
    totalTasks();
  }

  void totalTasks() async {
    String url = "http://192.168.0.103/auth_api/api/user_stats.php";
    Map data = {"uid": "21"};
    var jsonData = jsonEncode(data);
    var response = await http.post(Uri.encodeFull(url), body: jsonData);
    if (response.statusCode == 200) {
      // print(response.body);
      var finalData = jsonDecode(response.body.substring(15));
      setState(() {
        allTasks = finalData["allTasksdata"];
        allTasks = List.from(allTasks.reversed);
      });
      print(allTasks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Tasks Sorted Time Wise',
          style: TextStyle(color: Colors.orange),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Container(),
        ),
      ),
      body: ListView.builder(
        itemCount: allTasks.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: Colors.grey,
                ),
                title: Text(
                  '${allTasks[index]["task"]}',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 17,
                  ),
                ),
                subtitle: Text(
                  '${allTasks[index]["date_time"].toString().substring(11)}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Divider(
                color: Colors.grey,
              )
            ],
          );
        },
      ),
    );
  }
}
