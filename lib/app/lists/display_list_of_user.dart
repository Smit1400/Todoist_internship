import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoist/app/landing_page.dart';
import 'package:todoist/app/lists/add_list_page.dart';
import 'package:todoist/app/lists/display_list_bloc.dart';
import 'package:todoist/app/services/operations.dart';

class DisplayListOfUser extends StatefulWidget {
  bool today;
  bool priority;
  final DisplayListBloc bloc;
  DisplayListOfUser(
      {@required this.today, @required this.priority, @required this.bloc});

  static Widget create(BuildContext context,
      {bool today: false, bool priority: false}) {
    return Provider<DisplayListBloc>(
      create: (_) => DisplayListBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      child: Consumer<DisplayListBloc>(
          builder: (context, bloc, _) => DisplayListOfUser(
                today: today,
                priority: priority,
                bloc: bloc,
              )),
    );
  }

  @override
  _DisplayListOfUserState createState() => _DisplayListOfUserState();
}

class _DisplayListOfUserState extends State<DisplayListOfUser> {
  SharedPreferences sharedPreference;
  TextEditingController _controller;
  Operations object = OperationServices();

  void _addNewTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) {
            return AddListPage();
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  // this checks the login status of the user
  checkLoginStatus() async {
    sharedPreference = await SharedPreferences.getInstance();
    if (sharedPreference.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LandingPage()),
          (Route<dynamic> route) => false);
    }
  }

  //this method deletes a particular task by a user
  void _delete(String id) async {
    widget.bloc.setStreamData(
        {'loading': true, 'time': false, 'today': false, 'priority': false});
    await object.delete(id);
    widget.bloc.setStreamData(
        {'loading': false, 'time': false, 'today': false, 'priority': false});
  }

  // this method updates the task name of the user
  void _updateTask(Map data) async {
    widget.bloc.setStreamData(
        {'loading': true, 'time': false, 'today': false, 'priority': false});
    await object.updateTask(data);
    widget.bloc.setStreamData(
        {'loading': false, 'time': false, 'today': false, 'priority': false});
  }

  // this method is to set the priority of a task to 1
  void _starTask(Map data) async {
    widget.bloc.setStreamData(
        {'loading': true, 'time': false, 'today': false, 'priority': false});
    await object.starTask(data);
    widget.bloc.setStreamData(
        {'loading': false, 'time': false, 'today': false, 'priority': false});
  }

  void _unstarTask(Map data) async {
    widget.bloc.setStreamData(
        {'loading': true, 'time': false, 'today': false, 'priority': false});
    await object.unstarTask(data);
    widget.bloc.setStreamData(
        {'loading': false, 'time': false, 'today': false, 'priority': false});
  }

  // this method is to set the  of a task to completed
  void _completeTask(Map data) async {
    widget.bloc.setStreamData(
        {'loading': true, 'time': false, 'today': false, 'priority': false});
    await object.completeTask(data);
    widget.bloc.setStreamData(
        {'loading': false, 'time': false, 'today': false, 'priority': false});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Tasks',
            style: TextStyle(
              color: Colors.teal,
              fontSize: 25,
            ),
          ),
          actions: _actionContent()),
      body: StreamBuilder<Map<String, bool>>(
          stream: widget.bloc.stream,
          initialData: {
            'loading': false,
            'time': false,
            'today': false,
            'priority': false
          },
          builder: (context, snapshot) {
            if (snapshot.data['loading'] == true) {
              return _loading();
            }
            return _buildContent(context, snapshot.data);

            // return _loading();
          }),
      floatingActionButton: FlatButton(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.add_circle_outline,
              color: Colors.tealAccent,
            ),
            Text(
              'Add new task',
              style: TextStyle(color: Colors.tealAccent),
            ),
          ],
        ),
        onPressed: _addNewTask,
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, bool> streamData) {
    return StreamBuilder(
        stream: OperationServices().getfinalData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List data = snapshot.data;
            if (data.isNotEmpty) {
              data = snapshot.data;
              if (streamData['today'] == true || widget.today == true) {
                for (var instance in data) {
                  DateTime date = DateTime.parse(instance["date_time"]);
                  DateTime now = DateTime.now();
                  if (date.day != now.day ||
                      date.month != now.month ||
                      date.year != now.year) {
                    instance["date_time"] = "not today";
                  }
                }
              } else if (streamData['priority'] == true ||
                  widget.priority == true) {
                for (var instance in data) {
                  if (instance["priority"] == "0") {
                    instance["date_time"] = "not today";
                  }
                }
              } else if (streamData['time']) {
                data = List.from(data.reversed);
              } else {
                data = data;
              }
              return SafeArea(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, index) {
                    return data[index]["date_time"] == "not today"
                        ? Container()
                        : Dismissible(
                            key: Key('task-${DateTime.now()}'),
                            background: Container(
                                alignment: AlignmentDirectional.centerEnd,
                                color: Colors.red,
                                child: Icon(Icons.delete, color: Colors.white)),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) =>
                                _delete(data[index]["id"]),
                            child: ListTile(
                              leading: FlatButton(
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor:
                                        data[index]["status"] == "0"
                                            ? Colors.black
                                            : Colors.teal,
                                  ),
                                ),
                                onPressed: () {
                                  if (data[index]["status"] == "0") {
                                    print("COmpleted");
                                    _completeTask({
                                      "id": data[index]["id"],
                                      "status": "1"
                                    });
                                  } else {
                                    _completeTask({
                                      "id": data[index]["id"],
                                      "status": "0"
                                    });
                                  }
                                },
                              ),
                              title: data[index]["status"] == "1"
                                  ? Text('${data[index]["task"]}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          decoration:
                                              TextDecoration.lineThrough))
                                  : Text('${data[index]["task"]}',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18)),
                              trailing: FlatButton(
                                child: Icon(
                                  Icons.star,
                                  color: data[index]["priority"] == "0"
                                      ? Colors.grey[300]
                                      : Colors.teal,
                                ),
                                onPressed: () {
                                  if (data[index]["priority"] == "0") {
                                    _starTask({
                                      "id": data[index]["id"],
                                      "priority": "1"
                                    });
                                  } else {
                                    _unstarTask({
                                      "id": data[index]["id"],
                                      "priority": "0"
                                    });
                                  }
                                },
                              ),
                              onTap: () {
                                _controller = new TextEditingController(
                                    text: '${data[index]["task"]}');
                                _updateTaskDialog(data[index]["id"]);
                              },
                            ),
                          );
                  },
                ),
              );
            } else {
              return _emptyPageContent("");
            }
          } else if (snapshot.hasError) {
            _emptyPageContent("Some Error Occured");
          }
          return _loading();
        });
  }

  List<Widget> _actionContent() {
    return <Widget>[
      FlatButton.icon(
        onPressed: () {
          sharedPreference.clear();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LandingPage()),
              (Route<dynamic> route) => false);
        },
        icon: Icon(
          Icons.people,
          color: Colors.teal,
        ),
        label: Text('Logout', style: TextStyle(color: Colors.teal)),
      ),
      FlatButton.icon(
        onPressed: () async {
          var result = await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Container(
                    color: Colors.grey,
                    height: MediaQuery.of(context).size.height / 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Filter",
                            style: TextStyle(color: Colors.black, fontSize: 25),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: 320.0,
                            height: 50,
                            child: RaisedButton(
                              onPressed: () {
                                Navigator.pop(context, "Time");
                              },
                              child: Text(
                                "Time Wise Sort",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: 320.0,
                            height: 50,
                            child: RaisedButton(
                              onPressed: () {
                                Navigator.pop(context, "Today");
                              },
                              child: Text(
                                "Today\'s tasks",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: 320.0,
                            height: 50,
                            child: RaisedButton(
                              onPressed: () {
                                Navigator.pop(context, "Priority");
                              },
                              child: Text(
                                "Prioritized tasks",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: 320.0,
                            height: 50,
                            child: RaisedButton(
                              onPressed: () {
                                Navigator.pop(context, "All");
                              },
                              child: Text(
                                "All Tasks",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
          print(result);
          if (result == "Time") {
            final bloc = Provider.of<DisplayListBloc>(context, listen: false);
            bloc.setStreamData({
              'loading': false,
              'time': true,
              'today': false,
              'priority': false
            });
            if (widget.today == true || widget.priority == true) {
              setState(() {
                widget.today = false;
                widget.priority = false;
              });
            }
          }
          if (result == "Today") {
            final bloc = Provider.of<DisplayListBloc>(context, listen: false);
            bloc.setStreamData({
              'loading': false,
              'time': false,
              'today': true,
              'priority': false
            });
            if (widget.today == true || widget.priority == true) {
              setState(() {
                widget.today = false;
                widget.priority = false;
              });
            }
          }
          if (result == "All") {
            final bloc = Provider.of<DisplayListBloc>(context, listen: false);
            bloc.setStreamData({
              'loading': false,
              'time': false,
              'today': false,
              'priority': false
            });
            if (widget.today == true || widget.priority == true) {
              setState(() {
                widget.today = false;
                widget.priority = false;
              });
            }
          }
          if (result == "Priority") {
            final bloc = Provider.of<DisplayListBloc>(context, listen: false);
            bloc.setStreamData({
              'loading': false,
              'time': false,
              'today': false,
              'priority': true
            });
            if (widget.today == true || widget.priority == true) {
              setState(() {
                widget.today = false;
                widget.priority = false;
              });
            }
          }
        },
        icon: Icon(
          Icons.filter_list,
          color: Colors.teal,
        ),
        label: Text('Sort', style: TextStyle(color: Colors.teal)),
      ),
    ];
  }

  Widget _loading() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _emptyPageContent(String data) {
    return Container(
      child: Center(
        child: data != ""
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('$data',
                      style: TextStyle(fontSize: 37, color: Colors.grey)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Nothing Here',
                      style: TextStyle(fontSize: 45, color: Colors.grey)),
                  Text('Add new task',
                      style: TextStyle(fontSize: 25, color: Colors.grey))
                ],
              ),
      ),
    );
  }

  void _updateTaskDialog(String id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Update task",
                      style: TextStyle(color: Colors.teal, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.black),
                      controller: _controller,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[400],
                          border: InputBorder.none,
                          hintText: 'Task'),
                      onSubmitted: (value) {
                        print("value = $value");
                        _updateTask({"id": id, "task": "$value"});
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 320.0,
                      child: RaisedButton(
                        onPressed: () {
                          print('text = ${_controller.text}');
                          _updateTask(
                              {"id": id, "task": "${_controller.text}"});
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.teal,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
