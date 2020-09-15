enum oauth2Vendor{
  google,
  microsoft,
  yahoo
}

class Users{
  static String redirect_uri = "http://localhost:8080";
}

class UserInformation{
  String email;
  String name;
  String authorizationCode;
  String access_token;
  String refresh_token;
  oauth2Vendor vendor;
}