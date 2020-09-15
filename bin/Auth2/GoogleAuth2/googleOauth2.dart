import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../user-information.dart';

class GoogleOauth2{
  static String _baseLink = "https://oauth2.googleapis.com/token";
  static String _client_id = '990439782684-t224hulo9aegba964mqluborhhckhi5r.apps.googleusercontent.com';
  static String _client_secret = "Mjni8nmSayA1A9mrMM9EplJ4";

  static Future<Map> _getAccessToken(String code) async{
    http.Response response = await http.post(_baseLink, headers: {
      "Content-Type" : "application/x-www-form-urlencoded",
    },
    body: '''
      code=${code}&
      client_id=${_client_id}&
      client_secret=${_client_secret}&
      redirect_uri=${Users.redirect_uri}&
      grant_type=authorization_code
    '''
    );

    Map body = jsonDecode(response.body);
    return body;
  }

  static Future<Map> GetUserInformation(String code) async{
    Map accessMap = await _getAccessToken(code);
    print("accessMap:");
    print(accessMap);

    if(accessMap == null || accessMap.isEmpty || !accessMap.containsKey("access_token")){
      print("Can't find access token.");
      return null;
    }
     
    String access_token = accessMap["access_token"];
    int expires_in = accessMap["expires_in"];
    String refresh_token = accessMap["refresh_token"];

    String basedUrl = "https://people.googleapis.com/v1/people/me?";
    basedUrl += "?personFields=names,emailAddresses,addresses";

    http.Response response = await http.get(basedUrl, headers: {
      "Authorization" : "Bearer $access_token"
    });

    Map userInformationMap = jsonDecode(response.body);

    if(userInformationMap == null || !userInformationMap.containsKey("emailAddresses")){
      print("can't find user information");
      return null;
    }

    String email = userInformationMap["emailAddresses"][0];
    String name = userInformationMap["names"]
  }
}