import 'dart:io' as io;
import 'MicrosoftAuth2/handleMicrosoftAuth2.dart';
import 'MicrosoftAuth2/microsoftOauth2.dart';

Future main() async{
  String _host = io.InternetAddress.loopbackIPv4.host;
  MicrosoftOAuth2 msAuth = MicrosoftOAuth2();
  await msAuth.init();
  io.HttpServer server = await io.HttpServer.bind(_host, 4040);
  await for (io.HttpRequest request in server){
    handleRequest(request, msAuth);
  }
}

void handleRequest(io.HttpRequest request, MicrosoftOAuth2 msAuth) async{
  io.HttpResponse response = request.response;
  
  try{
    if(request.method == 'POST'){
      response.headers.contentType = io.ContentType.json;
      response.headers.add("Access-Control-Allow-Origin", "*");
      response.headers.add("Access-Control-Allow-Methods", "POST,GET,DELETE,PUT,OPTIONS");
      // oauth2 --- check microsoft login
      if(request.uri.pathSegments.last == "oauth2"){
        await handleAuth2(request, msAuth);
        response.statusCode = io.HttpStatus.ok;
      }else if(request.uri.pathSegments.last == "logout"){
        await handleLogout(request, msAuth);
        response.statusCode = io.HttpStatus.ok;
      }
    }
  }catch(e){
    
  }finally{
    await response.close();
  }
}