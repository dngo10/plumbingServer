import 'dart:ffi';
import 'dart:io' as io;

import 'Auth2/user-information.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import 'DatabaseConnect/data-information.dart';


Future main() async{
  String _host = io.InternetAddress.loopbackIPv4.host;

  io.HttpServer server = await io.HttpServer.bind(_host, 4040);
  print("server running at port: ${server.port}");
  await for (io.HttpRequest request in server){
    print("serving request...");
    handleRequest(request);
  }
}

void handleRequest(io.HttpRequest request) async{
  io.HttpResponse response = request.response;
  
  try{
    response.headers.contentType = io.ContentType.json;
    response.headers.add("Access-Control-Allow-Origin", "*");
    response.headers.add("Access-Control-Allow-Methods", "POST,GET,DELETE,PUT,OPTIONS");
    if(request.method == 'POST'){

      // oauth2 --- check microsoft login
      print("Post: ${request.connectionInfo.remoteAddress} - Method: ${request.uri.path}");
      if(request.uri.path == "/oauth2"){
        await Users.AddUser(request);
      }else if(request.uri.path == "/logout"){
        await Users.RemoveUser(request);
      }else if(request.uri.path == "/data" ){
        await Datas.AddData(request);
      }
    }else if(request.method == 'GET'){
      print("Get: ${request.connectionInfo.remoteAddress} - Method: ${request.uri.path}");
      if(request.uri.path == "/check_user"){
        await Users.CheckUser(request);
      }if(request.uri.path == "/data" &&
          request.uri.pathSegments != null &&
          request.uri.pathSegments.length > 0){
        await Datas.GetData(request);
      }
    }
  }catch(e){
    
  }finally{
    await response.close();
  }
}


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

// Future<void> main() async{
  // Uri url = Uri.parse("http://localhost:8080/auth2?code=asdfsdf&me=32344");
  // print(url.pathSegments);
  // print(url.queryParameters);
  // print(url.path);
  // DateTime abc = DateTime.parse(DateTime.now().toUtc().toString());
  // String sql = "INSERT INTO \'USER_INFORMATION\' ";
  // sql += "(name, ";
  // sql += "email, ";
  // sql += "code, ";
  // sql += "date_created, ";
  // sql += "token, ";
  // sql += "refresh_token, ";
  // sql += "id_token, ";
  // sql += "expires_in, ";
  // sql += "vendor) ";
  // sql += "VALUES (";
  // sql += "'abc','abc','acb','abc','abc','abc',NULL,0,'abc');";
  // print(sql);
  // Database db = await SqliteHelper.openDb();
  // print(db);
  // await db.execute(sql);
  // await SqliteHelper.closeDb(db);

  // print(abc);
  // //ConnectSqlite();
// }

//Will lua be relevant ?