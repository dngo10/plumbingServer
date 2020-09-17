import 'dart:convert';
import 'package:http/http.dart' as http;

import '../user-information.dart';

class GoogleOauth2{
  static String _baseLink = "https://oauth2.googleapis.com/token";
  static String _revokeLink = "https://oauth2.googleapis.com/revoke?";
  static String _client_id = '990439782684-t224hulo9aegba964mqluborhhckhi5r.apps.googleusercontent.com';
  static String _client_secret = "Mjni8nmSayA1A9mrMM9EplJ4";

  static Future<Map> _getAccessToken(String code) async{
    http.Response response = await http.post(_baseLink, headers: {
      "Content-Type" : "application/x-www-form-urlencoded",
    },
    body: _getAccessBody(code)
    );
    Map body = jsonDecode(response.body);
    return body;
  }

  static String _getAccessBody(String code){
    String body = "code=${code}&";
    body += "client_id=${_client_id}&";
    body += "client_secret=${_client_secret}&";
    body += "grant_type=authorization_code&";
    body += "redirect_uri=${Users.redirect_uri}";
    return body;
  }

  static String _getRefreshBody(UserInformation usr){
    String body = "client_id=${_client_id}&";
    body += "client_secret=${_client_secret}&";
    body += "refresh_token=${usr.refresh_token}&";
    body += "grant_type=refresh_token";
    return body;
  }

  static Future<Map> _getRefreshToken(UserInformation usr) async{
    http.Response response = await http.post(_baseLink, headers:{
      "Content-Type" : "application/x-www-form-urlencoded",
    },
    body: _getRefreshBody(usr)
    );

    Map body = jsonDecode(response.body);
    return body;
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

    String basedUrl = "https://people.googleapis.com/v1/people/me";
    basedUrl += "?personFields=names,emailAddresses,addresses";

    http.Response response = await http.get(basedUrl, headers: {
      "Authorization" : "Bearer $access_token"
    });

    Map userInformationMap = jsonDecode(response.body);

    if(userInformationMap == null || !userInformationMap.containsKey("emailAddresses")){
      print("can't find user information");
      return null;
    }

    String email = userInformationMap["emailAddresses"][0]["value"];
    String name = userInformationMap["names"][0]["displayName"];

    UserInformation usr = UserInformation();
    usr.creationTime = DateTime.now().toUtc();
    usr.email = email;
    usr.name = name;
    usr.access_token = access_token;
    usr.refresh_token =refresh_token;
    usr.authorizationCode = code;
    usr.vendor = oauth2Vendor.google;
    usr.expires_in = expires_in;
    usr.id_token = id_token;
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

  static Future<bool> logout(UserInformation usr) async{
    await http.post(_revokeLink + "token=" + usr.access_token,
    headers: {
      "Content-type": "application/x-www-form-urlencoded"
    }
    );
    return true;
  }
}