import 'dart:convert';

import 'package:http/http.dart' as http;

import '../user-information.dart';

class MicrosoftOAuth2{
  static String _basedLink = "https://login.microsoftonline.com/common/v2.0/oauth2/token";
  static String _client_id = "0c0b0622-f612-41a6-874c-b5182b5183f1";
  static String _tenant = "common";
  static String _scope = "email openid profile https://graph.microsoft.com/User.Read";
  static String _client_secret = ".E52-2~MYp_-OSuW9FgRfKurta5JgIlHGN";
  static String _redirect_url = "http://localhost:8080";

  static String _generateAccessTokenBody(String code){
    String ans = "";
    ans += "grant_type=authorization_code";
    ans += "&client_id=${_client_id}";
    ans += "&redirect_uri=${_redirect_url}";
    ans += "&scope=${_scope}";
    ans += "&code=${code}";
    ans += "&client_secret=${_client_secret}";
    return ans;
  }

  static Future<Map> _getAccessToken(String code) async{
    http.Response response = await http.post(_basedLink, headers:{
      "Content-Type" : "application/x-www-form-urlencoded",
    },
    body: _generateAccessTokenBody(code)
    );

    Map body = jsonDecode(response.body);
    return body;
  }

  static String _generateRefreshTokenBody(UserInformation usr){
    String ans = "";
    ans += "grant_type=refresh_token";
    ans += "&client_id=${_client_id}";
    ans += "&redirect_uri=${_redirect_url}";
    ans += "&scope=${_scope}";
    ans += "&refresh_token=${usr.refresh_token}";
    ans += "&client_secret=${_client_secret}";
    return ans;
  }

  static Future<Map> _getRefreshToken(UserInformation usr) async{
    http.Response response = await http.post(_basedLink, headers: {
      "Content-Type" : "application/x-www-form-urlencoded",
    },
    body: _generateAccessTokenBody(usr.authorizationCode)
    );
    Map map = jsonDecode(response.body);

    return map;
  }

  static Future<UserInformation> GetUserInformation(String code) async{
    Map accessMap = await _getAccessToken(code);

    if(accessMap == null || accessMap.isEmpty || !accessMap.containsKey("access_token")){
      print("Can't find access token.");
      return null;
    }

    String access_token = accessMap["access_token"];
    int expires_in = accessMap["expires_in"];
    String refresh_token = accessMap["refresh_token"];
    String id_token = accessMap["id_token"];

    String basedUrl = "https://graph.microsoft.com/v1.0/me";

    http.Response response = await http.get(basedUrl, headers: {
      "Authorization" : "Bearer $access_token"
    });

    Map userInformationMap = jsonDecode(response.body);

    if(userInformationMap == null || !userInformationMap.containsKey("userPrincipalName")){
      print("can't find user information");
      return null;
    }

    String name = userInformationMap["displayName"];
    String email = userInformationMap["userPrincipalName"];

    UserInformation usr = UserInformation();
    usr.access_token = access_token;
    usr.authorizationCode  = code;
    usr.creationTime = DateTime.now().toUtc();
    usr.email = email;
    usr.name = name;
    usr.expires_in = expires_in;
    usr.refresh_token = refresh_token;
    usr.id_token = id_token;
    usr.vendor =oauth2Vendor.microsoft;
    return usr;
  }

  static Future<bool> refresh_token(UserInformation usr) async{
    Map map = await _getRefreshToken(usr);
    if(map == null || map.isEmpty || !map.containsKey("access_token")){
      return false;
    };

    usr.creationTime = DateTime.now().toUtc();
    usr.expires_in = map["expires_in"];
    usr.access_token = map["access_token"];
    return true;
  }
}