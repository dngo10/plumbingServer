import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;

import '../user-information.dart';

class YahooOauth2{
  static String _baseLink = "https://api.login.yahoo.com/oauth2/get_token";
  static String _client_id = 'dj0yJmk9Snk0aHdEZVNKRDBDJmQ9WVdrOVVVaHpTM050TjNNbWNHbzlNQT09JnM9Y29uc3VtZXJzZWNyZXQmc3Y9MCZ4PTll';
  static String _client_secret = "5e8a4e1a1edcdd66fcbaf88f68b5ae0a2b3585fb";
  

  static Future<Map> _getAccessToken(String code) async{
    List<int> bytes = utf8.encode(_client_secret);
    String base64tr = base64.encode(bytes);

    http.Response response = await http.post(_baseLink, headers: {
      "Content-Type" : "application/x-www-form-urlencoded",
      "Authorization": "Basic ${base64tr}"
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

  static Future<Map> _getRefreshToken(UserInformation usr) async{
    List<int> bytes = utf8.encode(_client_secret);
    String base64tr = base64.encode(bytes);

    http.Response response = await http.post(_baseLink, headers:{
      "Content-Type" : "application/x-www-form-urlencoded",
      "Authorization": "${base64tr}"
    },
    body: '''
      client_id=${_client_id}&
      client_secret=${_client_secret}&
      refresh_token=${usr.refresh_token}&
      grant_type=refresh_token
    '''
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
    //String id_token = accessMap["id_token"]; // There is no id_token in Yahoo

    String basedUrl = "api.login.yahoo.com/openid/v1/userinfo";
    //basedUrl += "?personFields=names,emailAddresses,addresses";

    http.Response response = await http.get(basedUrl, headers: {
      "Authorization" : "Bearer $access_token"
    });

    Map userInformationMap = jsonDecode(response.body);

    if(userInformationMap == null || !userInformationMap.containsKey("emailAddresses")){
      print("can't find user information");
      return null;
    }

    String email = userInformationMap["email"];
    String name = userInformationMap["name"];

    UserInformation usr = UserInformation();
    usr.creationTime = DateTime.now().toUtc();
    usr.email = email;
    usr.name = name;
    usr.access_token = access_token;
    usr.refresh_token =refresh_token;
    usr.authorizationCode = code;
    usr.vendor = oauth2Vendor.google;
    usr.expires_in = expires_in;
    //usr.id_token = id_token; // There is no id_token
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