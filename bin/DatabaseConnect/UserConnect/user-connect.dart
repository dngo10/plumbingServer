import 'package:sqlite3/sqlite3.dart';
import '../../Auth2/user-information.dart';



class UserConnect{

  static Future<bool> AddUser(UserInformation usr, Database db) async{
    String sql = 'INSERT INTO \"${usrGoodie.userInfo}\" ';
    sql += '(${usrGoodie.name}, ';
    sql += '${usrGoodie.email}, ';
    sql += '${usrGoodie.code}, ';
    sql += '${usrGoodie.date_created.toString()}, ';
    sql += '${usrGoodie.token}, ';
    sql += '${usrGoodie.refresh_token}, ';
    sql += '${usrGoodie.id_token}, ';
    sql += '${usrGoodie.expires_in}, ';
    sql += '${usrGoodie.vendor}) ';
    sql += 'VALUES (\"${usr.name}\", ';
    sql += '\"${usr.email}\", ';
    sql += '\"${usr.authorizationCode}\", '; //
    sql += '\"${usr.creationTime.toString()}\", ';
    sql += '\"${usr.access_token}\", ' ; //
    sql += '\"${usr.refresh_token}\", '; //
    sql += '\"${usr.id_token}\", '; //
    sql += '${usr.expires_in.toString()}, ';
    sql += '\"${Users.vendorDict[usr.vendor]}\");';
    await db.execute(sql);
    return true;
  }

  static bool HasUser(String authorizationCode, Database db){
    ResultSet result = db.select('SELECT ${usrGoodie.code} FROM ${usrGoodie.userInfo} WHERE ${usrGoodie.code} = ?', [authorizationCode]);
    if(result.length == 1){
      return true;
    }
    return false;
  }

  static UserInformation GetUser(String authorizationCode, Database db){
      if(HasUser(authorizationCode, db)){
        ResultSet resultSet = db.select('SELECT * FROM ${usrGoodie.userInfo} WHERE ${usrGoodie.code} = ?', [authorizationCode]);
        Row r = resultSet.first;
        UserInformation uinfo = UserInformation();
        uinfo.email = r[usrGoodie.email] as String;
        uinfo.name = r[usrGoodie.name] as String;
        uinfo.authorizationCode = r[usrGoodie.code] as String;
        uinfo.creationTime = DateTime.parse(r[usrGoodie.date_created] as String);
        uinfo.access_token = r[usrGoodie.token] as String;
        uinfo.refresh_token = r[usrGoodie.refresh_token] as String;
        uinfo.id_token = r[usrGoodie.id_token] as String;
        uinfo.expires_in = r[usrGoodie.expires_in] as int;
        String vendor = r[usrGoodie.vendor] as String;
        if(vendor == "microsoft") uinfo.vendor = oauth2Vendor.microsoft;
        if(vendor == "google") uinfo.vendor = oauth2Vendor.google;
        if(vendor == "yahoo") uinfo.vendor = oauth2Vendor.yahoo;
        return uinfo;
      }
      return null;
  }

  static bool DeleteUser(String authorizationCode, Database db){
    String sql = 'DELETE FROM ${usrGoodie.userInfo} WHERE ${usrGoodie.code} = \"${authorizationCode}\";';
    db.execute(sql);
    return true;
  }
}

class usrGoodie{
  static String userInfo = "USER_INFORMATION"; // Table name
  static String name = 'name';
  static String code = 'code';
  static String email = 'email';
  static String date_created = 'date_created';
  static String token = 'token';
  static String refresh_token = 'refresh_token';
  static String id_token = 'id_token';
  static String expires_in = 'expires_in';
  static String vendor = 'vendor';
}