import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class Operations {
  Future<void> delete(String id);
  Future listOfTasks();
  Future<void> updateTask(Map data);
  Future<void> starTask(Map data);
  Future<void> unstarTask(Map data);
  Future<void> completeTask(Map data);
}

class OperationServices extends Operations {
  SharedPreferences sharedPreference;
  List finalData = List();

  Future listOfTasks() async {
    String validateUrl =
        "https://todoistapi.000webhostapp.com/validate_token.php";
    sharedPreference = await SharedPreferences.getInstance();
    String jwtToken = sharedPreference.getString("token");
    Map data = {"jwt": jwtToken};
    var jsonDataEncode = jsonEncode(data);
    var response =
        await http.post(Uri.encodeFull(validateUrl), body: jsonDataEncode);
    if (response.statusCode == 200) {
      var userDataDecoded = jsonDecode(response.body);
      Map userData = userDataDecoded["data"];
      String uid = userData["id"];
      String displayTaskUrl =
          "https://todoistapi.000webhostapp.com/user_stats.php";
      Map dataId = {"uid": uid};
      var jsonDataId = jsonEncode(dataId);
      var displayResponse =
          await http.post(Uri.encodeFull(displayTaskUrl), body: jsonDataId);
      if (displayResponse.statusCode == 200) {
        finalData = jsonDecode(displayResponse.body.toString())["allTasksdata"];
        // print(finalData);
        return finalData;
      }
    }
    return finalData;
  }

  Stream get getfinalData async* {
    yield await listOfTasks();
  }

  Future<void> completeTask(Map data) async {
    var updateJsonData = jsonEncode(data);
    String url = "https://todoistapi.000webhostapp.com/complete_task.php";
    var response = await http.post(Uri.encodeFull(url), body: updateJsonData);
    if (response.statusCode == 200) {}
  }

  Future<void> starTask(Map data) async {
    var updateJsonData = jsonEncode(data);
    String url = "https://todoistapi.000webhostapp.com/star_task.php";
    var response = await http.post(Uri.encodeFull(url), body: updateJsonData);
    if (response.statusCode == 200) {}
  }

  Future<void> unstarTask(Map data) async {
    var updateJsonData = jsonEncode(data);
    String url = "https://todoistapi.000webhostapp.com/unstar_task.php";
    var response = await http.post(Uri.encodeFull(url), body: updateJsonData);
    if (response.statusCode == 200) {}
  }

  Future<void> delete(String id) async {
    Map data = {"id": id};
    var jsonData = jsonEncode(data);
    String deleteUrl = "https://todoistapi.000webhostapp.com/delete_task.php";
    var response = await http.post(Uri.encodeFull(deleteUrl), body: jsonData);
    if (response.statusCode == 200) {
      print(response.body);
    }
  }

  Future<void> updateTask(Map data) async {
    var updateJsonData = jsonEncode(data);
    String url = "https://todoistapi.000webhostapp.com/update_task.php";
    var response = await http.post(Uri.encodeFull(url), body: updateJsonData);
    if (response.statusCode == 200) {
      print(response.body);
    }
  }
}
