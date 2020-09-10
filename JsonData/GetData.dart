import 'dart:convert';
import 'dart:io';

Future<Map> getMap(String path) async{
  File jsonFile = File(path);
  Map data;
  Future<String> futureJson = jsonFile.readAsString();
  await futureJson.then((value){
      data =  jsonDecode(value);
  });
  return data;
}