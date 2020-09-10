import 'dart:convert';

import '../../JsonData/GetData.dart' as GetData;
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class MicrosoftOAuth2{
  Map data;
  String _path = 'JsonData/MicrosoftOAuth2.json';
  Map<String, TokenElement> tokens; // String is the authorization_code

  MicrosoftOAuth2(){
    tokens = Map<String, TokenElement>();
  }

  Future<void> init() async{
    data = await GetData.getMap(_path);
  }

  String _getPostString(){
    String postStr = '${data["host"]}/${data["tenant"]}/${data["after_tenant"]}';
    return postStr;
  }

  void _addToken(TokenElement e){
    if(tokens.containsKey(e.code)){
      _refreshToken(e.code);// Actually we will do refresh token here
    }else{
      tokens[e.code] = e;
    }
  }

  String _generateAccessTokenBody(String code){
    String ans = "";
    ans += "grant_type=authorization_code";
    ans += "&client_id=${data['client_id']}";
    ans += "&redirect_uri=${data['redirect_uri']}";
    ans += "&scope=${data['scope']}";
    ans += "&code=${code}";
    ans += "&client_secret=${data['client_secret']}";
    return ans;
  }

  String _generateRefreshTokenBody(TokenElement element){
    String ans = "";
    ans += "grant_type=refresh_token";
    ans += "&client_id=${data['client_id']}";
    ans += "&redirect_uri=${data['redirect_uri']}";
    ans += "&scope=${data['scope']}";
    ans += "&refresh_token=${element.refresh_token}";
    ans += "&client_secret=${data['client_secret']}";
    return ans;
  }

  Future<void> getAccessToken(HttpRequest request) async{
    List contextu = await request.toList();
    HttpResponse response = request.response;
    Map data;

    contextu.forEach((element){
      String content = utf8.decode(element);
      data = jsonDecode(content);
    });

    if(data != null && data.containsKey("code")){
      http.Response tokenResponse = await http.post(_getPostString(),
          headers: {
                    "Accept": "application/json",
                    "Content-Type": "application/x-www-form-urlencoded"
          },
          body: _generateAccessTokenBody(data["code"]),
          encoding: Encoding.getByName("utf-8")
          );
      if(tokenResponse != null){
        Map tokenJson = jsonDecode(tokenResponse.body);
        if(tokenJson["access_token"] == null) {
          print("can't find access_token");
          return;
        }
        TokenElement tElement = TokenElement(tokenJson, data["code"]);
        await tElement.init();
        if(tElement.authStatus != null && tElement.authStatus.status == "ok"){
          response.write(tElement.authStatus.toJson());
          _addToken(tElement);
        }
      }
    }
  }

  Future<void> _refreshToken(String code) async{
    if(tokens.containsKey(code) && _isValidCode(code)){
      TokenElement element = tokens[code];
      String requestBody = _generateRefreshTokenBody(element);
      http.Response response = await http.post(_getPostString(),
        headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"          
        },
        body: requestBody
      );
      Map responseMap = jsonDecode(response.body);
      if(!responseMap.containsKey("error"))
        tokens[code] = TokenElement(responseMap, code);
    }
  }

  void logout(HttpRequest request) async{
    HttpResponse response = request.response;
    List contextu = await request.toList();
    Map data;

    contextu.forEach((element){
      String content = utf8.decode(element);
      data = jsonDecode(content);
    });

    if(data.containsKey("code")){
      String code = data["code"] as String;
      if(tokens.containsKey(code)){
        tokens.remove(code);
        Map sMap = {
          "status": "ok",
          "message": "${code} is removed."
        };
        response.write(json.encode(sMap));
      }else{
        Map sMap = {
          "status": "notfound",
          "message": "couldn't find"
        };
        response.write(json.encode(sMap));
      }
    }else{
      Map sMap ={
        "status": "nocode",
        "message": "couldn't find user authorization code"
      };
      response.write(json.encode(sMap));
    }
  }

  _isValidCode(String code){
    if(tokens.containsKey(code) &&
       tokens[code].isValid()
    ){
      return true;
    }
    return false;
  }
}

class TokenElement{
  Hash hasher = md5;

  String token_type;
  String scope;
  int expires_in;       // in second
  int ext_expires_in;   // in second
  DateTime createTime;
  String access_token;
  String refresh_token;
  String id_token;
  String code;
  AuthStatus authStatus;

  TokenElement(Map tokenResponse, String code){
    _mapToVariable(tokenResponse);
    createTime = DateTime.now().toUtc();
    this.code = code;
  }

  _mapToVariable(Map tokenResponse){
    token_type = tokenResponse['tokenResponse'];
    scope = tokenResponse['scope'];
    expires_in = tokenResponse['expires_in'];
    ext_expires_in = tokenResponse['ext_expires_in'];
    access_token = tokenResponse['access_token'];
    refresh_token = tokenResponse['refresh_token'];
    id_token = tokenResponse['id_token'];
  }

  Future<void> init() async{
    if(refresh_token != null && access_token != null)
    await _getUserInformation();
  }

  isValid(){
    if(authStatus == null || authStatus?.status == "error") return false;
    DateTime now = DateTime.now().toUtc();
    if(now.difference(createTime).inSeconds <= expires_in){
      return false;
    }
    return true;
  }

  void _getUserInformation() async{
    String endPoint = "https://graph.microsoft.com/v1.0/me";
    if(access_token == null) return;
    final response = await http.get(endPoint,
      headers: {
        'Authorization': "Bearer $access_token",
        'Content-Type': 'application/json',
      }
    );

    Map bodyMap = jsonDecode(response.body);
    authStatus = AuthStatus(bodyMap);
  }
}

//===========================================================
class AuthStatus{
  final _principalName = "userPrincipalName";
  final _mail = "mail";
  final _displayName = "displayName";
  final _emailRegex = r"^[a-zA-Z]+[\d]*@gouvisgroup.com$";

  final _error = "error";
  final _error_description = "error_description";

  RegExp _reg ;

  String status;
  String email;
  String displayName;
  String message; // message what happends.

  AuthStatus(Map response){
    _reg = RegExp(_emailRegex,caseSensitive: false);
    if(_checkResponseStatus(response) && _getEmail(response)){
      message = "user is legit";
    }else{
      displayName = response[_error];
      message = response[_error_description];
    }
  }
  
  bool _checkResponseStatus(Map response){
    if(response.containsKey(_principalName)){
      displayName = response[_displayName];
      status = "ok";
      return true;
    }
    status = "error";
    return false;
  }
  
  bool _getEmail(Map reponse){
    String maybeEmail;
    bool hasEmail = false;
    if(reponse.containsKey(_principalName)){
      maybeEmail = reponse[_principalName];
      if(_reg.hasMatch(maybeEmail)){
        email = maybeEmail;
        hasEmail = true;
      }
    }else if(reponse.containsKey(_mail)){
      maybeEmail = reponse[_mail];
      if(_reg.hasMatch(maybeEmail)){
        email = maybeEmail;
        hasEmail = true;
      }
    }
    return hasEmail;
  }

  String toJson(){
    Map<String,String> sMap = {
      "status": status,
      "email": email,
      "displayName": displayName,
      "message": message,
    };
    return json.encode(sMap);
  }
}

// Client Secret xtS8c2OFHN-lnRaAVz2l-Zb3qNz~54lm~G
