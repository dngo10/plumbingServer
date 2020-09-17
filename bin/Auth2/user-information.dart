import 'dart:convert';
import 'dart:io' as io;

import 'GoogleAuth2/googleOauth2.dart';
import 'MicrosoftAuth2/microsoftOauth2.dart';

import 'YahooAuth2/yahooOauth2.dart';

enum oauth2Vendor{
  google,
  microsoft,
  yahoo
}

class Users{
  static String redirect_uri = "http://localhost:8080";
  static Map<oauth2Vendor, String> vendorDict = {
    oauth2Vendor.google : "google",
    oauth2Vendor.microsoft : "microsoft",
    oauth2Vendor.yahoo: "yahoo"
  };

  static Map<String, UserInformation> usersMap = Map<String, UserInformation>();

  static Future<bool>  AddUser(io.HttpRequest request) async{
    io.HttpResponse  reponse = request.response;
    String content = await utf8.decodeStream(request);
    Map map = jsonDecode(content);
    if(map == null || map.isEmpty || !map.containsKey("code")) return false;

    String vendor = map["vendor"];
    String code = map["code"];
    if(vendor == null) return false;
    
    UserInformation usr = await  _getUser(vendor, code);
    if(usr != null){
      usersMap[code] = usr;
      print(usr.toJson());
      reponse.write(usr.toJson());
      return true;
    }
    return false;
  }

  static Future<bool> RemoveUser(io.HttpRequest request) async{
    io.HttpResponse response = request.response;
    String content = await utf8.decodeStream(request);
    Map map = jsonDecode(content);
    if(map == null || map.isEmpty || !map.containsKey("code")) return false;

    String code = map["code"];
    if(usersMap != null && usersMap.containsKey(code)){
      UserInformation usr = usersMap[code];
      usr.logOut(request);
      usersMap.remove(code);
      Map logOutmap = {
        "status": "ok",
        "message": "removed",
      };
      response.write(jsonEncode(logOutmap));
      response.statusCode = io.HttpStatus.ok;
      return true;
    }
    Map logOutmap = {
        "status": "error",
        "message": "logout not complete",
    };
    response.write(jsonEncode(logOutmap));
    response.statusCode = io.HttpStatus.notFound;
    return false;
  }

  static Future<UserInformation> _getUser(String vendor, String code) async{
    if(vendor == "google"){
      return await GoogleOauth2.GetUserInformation(code);
    }if(vendor == "yahoo"){
      return await YahooOauth2.GetUserInformation(code);
    }if(vendor == "microsoft"){
      return await MicrosoftOAuth2.GetUserInformation(code);
    }
    return null;
  }

  static Future<void> CheckUser(io.HttpRequest request) async{
    Map paras = request.uri.queryParameters;
    if(paras != null && paras.containsKey("code")){
      String code = paras["code"];
      if(usersMap.containsKey(code)){
        Map map ={
          "status": "ok",
          "message": "user found"
        };
        request.response.write(jsonEncode(map));
      }else{
        Map map = {
          "status": "error",
          "message": "cant Find user for code: $code",
        };
        request.response.write(jsonEncode(map));
      }
    }
  }
}

class UserInformation{
  String id_token;
  String email;
  String name;
  String authorizationCode;
  String access_token;
  String refresh_token;
  int expires_in;
  DateTime creationTime;
  String status;
  oauth2Vendor vendor;

  bool isValid(){
    if(creationTime.difference(DateTime.now().toUtc()).inSeconds > expires_in*0.8){
      return false;
    }
    return true;
  }

  Future<bool> refreshToken() async{
    if(vendor == oauth2Vendor.google){
      return await GoogleOauth2.refresh_token(this);
    }else if(vendor == oauth2Vendor.microsoft){
      return await MicrosoftOAuth2.refresh_token(this);
    }else if(vendor == oauth2Vendor.yahoo){
      return await YahooOauth2.refresh_token(this);
    }
    return false;
  }

  Future<bool> logOut(io.HttpRequest request) async{
    if(vendor == oauth2Vendor.google){
      return await GoogleOauth2.logout(this);
    }
    return false;
  }

  String toJson(){
    if((name != null && !name.isEmpty) &&
       (email != null && !email.isEmpty)){
         status = "ok";
    }else{
      status = "error";
    }


    Map temp = {
      "name" : name,
      "email": email,
      "expires_in": expires_in,
      "status": status
    };

    return jsonEncode(temp);
  }

}

