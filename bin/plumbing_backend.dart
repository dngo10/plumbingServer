import 'dart:io' as io;

import 'Auth2/user-information.dart';

Future main() async{
  String _host = io.InternetAddress.loopbackIPv4.host;

  io.HttpServer server = await io.HttpServer.bind(_host, 4040);
  await for (io.HttpRequest request in server){
    handleRequest(request);
  }
}

void handleRequest(io.HttpRequest request) async{
  io.HttpResponse response = request.response;
  
  try{
    if(request.method == 'POST'){
      response.headers.contentType = io.ContentType.json;
      response.headers.add("Access-Control-Allow-Origin", "*");
      response.headers.add("Access-Control-Allow-Methods", "POST,GET,DELETE,PUT,OPTIONS");
      // oauth2 --- check microsoft login
      if(request.uri.pathSegments.last == "oauth2"){
        print("get Post request from: ${request.connectionInfo.remoteAddress}");
        await Users.AddUser(request);
        response.statusCode = io.HttpStatus.ok;
      }else if(request.uri.pathSegments.last == "logout"){
        //Implement later
      }
    }
  }catch(e){
    
  }finally{
    await response.close();
  }
}

//Future<void> main() async{
//  Uri url = Uri.parse("http://localhost:8080/auth2?code=asdfsdf&me=32344");
//  print(url.pathSegments);
//  print(url.queryParameters);
//}