import 'dart:ffi';
import 'dart:io' as io;

import 'Auth2/user-information.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

//Future main() async{
//  String _host = io.InternetAddress.loopbackIPv4.host;
//
//  io.HttpServer server = await io.HttpServer.bind(_host, 4040);
//  print("server running at port: ${server.port}");
//  await for (io.HttpRequest request in server){
//    handleRequest(request);
//  }
//}
//
//void handleRequest(io.HttpRequest request) async{
//  io.HttpResponse response = request.response;
//  
//  try{
//    response.headers.contentType = io.ContentType.json;
//    response.headers.add("Access-Control-Allow-Origin", "*");
//    response.headers.add("Access-Control-Allow-Methods", "POST,GET,DELETE,PUT,OPTIONS");
//    if(request.method == 'POST'){
//
//      // oauth2 --- check microsoft login
//      print("Post: ${request.connectionInfo.remoteAddress} - Method: ${request.uri.pathSegments.last}");
//      if(request.uri.pathSegments.last == "oauth2"){
//        bool result = await Users.AddUser(request);
//      }else if(request.uri.pathSegments.last == "logout"){
//        bool result = await Users.RemoveUser(request);
//      }
//    }else if(request.method == 'GET'){
//      print("Get: ${request.connectionInfo.remoteAddress} - Method: ${request.uri.pathSegments.last}");
//      if(request.uri.pathSegments.last == "check_user"){
//        await Users.CheckUser(request);
//      }
//    }
//  }catch(e){
//    
//  }finally{
//    await response.close();
//  }
//}

//ADD DATABASE
void ConnectSqlite(){
  open.overrideFor(OperatingSystem.windows, _openOnWindow);
  print('Using sqlite3 ${sqlite3.version}');
  final db = sqlite3.open("gouvis.db");
  db.dispose();
}

DynamicLibrary _openOnWindow(){
  //final script = io.File(io.Platform.script.toFilePath());
  final libraryNextToScript = io.File('sqlite3.dll');
  return DynamicLibrary.open(libraryNextToScript.path);
}

Future<void> main() async{
  Uri url = Uri.parse("http://localhost:8080/auth2?code=asdfsdf&me=32344");
  print(url.pathSegments);
  print(url.queryParameters);
  ConnectSqlite();
}