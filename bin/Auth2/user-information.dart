import 'dart:convert';
import 'dart:io' as io;

import 'package:sqlite3/sqlite3.dart';

import '../DatabaseConnect/SqliteHandle/sqlite-open-close.dart';
import '../DatabaseConnect/UserConnect/user-connect.dart';
import 'GoogleAuth2/googleOauth2.dart';
import 'MicrosoftAuth2/microsoftOauth2.dart';

enum oauth2Vendor{
  google,
  microsoft,
  yahoo
}

class Users{
  static Map<oauth2Vendor, String> vendorDict = {
    oauth2Vendor.google : "google",
    oauth2Vendor.microsoft : "microsoft",
    oauth2Vendor.yahoo: "yahoo"
  };

  //static Map<String, UserInformation> usersMap = Map<String, UserInformation>();

  static Future<bool>  AddUser(io.HttpRequest request) async{
    io.HttpResponse  reponse = request.response;
    String content = await utf8.decodeStream(request);
    Map map = jsonDecode(content);
    if(map == null || map.isEmpty || !map.containsKey("code")) return false;

    String vendor = map["vendor"];
    String code = map["code"];
    String redirect_uri = map["redirect_uri"];
    if(vendor == null) return false;
    
    UserInformation usr = await  _getUser(vendor, code, redirect_uri);
    if(usr != null){
      Database db = await SqliteHelper.openDb();
      await UserConnect.AddUser(usr, db);
      await SqliteHelper.closeDb(db);
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
    Database db = SqliteHelper.openDb();
    UserInformation usr = UserConnect.GetUser(code, db);
    if(usr != null){
      await usr.logOut(request);
      await UserConnect.DeleteUser(code, db);
      Map logOutmap = {
        "status": "ok",
        "message": "removed",
      };
      response.write(jsonEncode(logOutmap));
      response.statusCode = io.HttpStatus.ok;
    }
    Map logOutmap = {
        "status": "error",
        "message": "logout not complete",
    };
    print(logOutmap);
    response.write(jsonEncode(logOutmap));
    response.statusCode = io.HttpStatus.notFound;
    await SqliteHelper.closeDb(db);
    return true;
  }

  static Future<UserInformation> _getUser(String vendor, String code, String redirect_uri) async{
    if(vendor == "google"){
      return await GoogleOauth2.GetUserInformation(code, redirect_uri);
    }if(vendor == "microsoft"){
      return await MicrosoftOAuth2.GetUserInformation(code, redirect_uri);
    }
    return null;
  }

  static Future<void> CheckUser(io.HttpRequest request) async{
    Map paras = request.uri.queryParameters;
    if(paras != null && paras.containsKey("code")){
      String code = paras["code"];
      Database db = SqliteHelper.openDb();
      bool hasUser = UserConnect.HasUser(code, db);
      SqliteHelper.closeDb(db);
      if(hasUser){
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

  Future<bool> refreshToken(String redirect_uri) async{
    if(vendor == oauth2Vendor.google){
      return await GoogleOauth2.refresh_token(this);
    }else if(vendor == oauth2Vendor.microsoft){
      return await MicrosoftOAuth2.refresh_token(this, redirect_uri);
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

