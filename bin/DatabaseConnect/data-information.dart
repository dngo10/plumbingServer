import 'dart:convert';
import 'dart:io' as io;
import 'package:sqlite3/sqlite3.dart';

import 'DataConnect/data-connect.dart';
import 'SqliteHandle/sqlite-open-close.dart';

class Datas{
  
  /// Re
  static Future<void> GetData(io.HttpRequest request) async{
    Map dataMap = request.uri.queryParameters;
    if(dataMap.containsKey(DataHelper.code) &&
       dataMap.containsKey(DataHelper.id)
    ){
      int id = int.parse(dataMap[DataHelper.id]);
      String code = dataMap[DataHelper.code];
      DataHeader dh = DataHeader();
      dh.code = code;
      dh.id = id;

      Database db = SqliteHelper.openDb();
      CommandData data = DataConnect.GetData(dh, db);
      SqliteHelper.closeDb(db);
      request.response.write(data.toJson());
    }
  }

  static Future<void> AddData(io.HttpRequest request) async{
    String dataJson =  await utf8.decodeStream(request);
    CommandData data = DataConnect.jsonToData(dataJson);
    if(data != null){
      DataHeader hd = DataHeader.jsonToDataHeader(dataJson);
      Database db = SqliteHelper.openDb();
      int returnId = DataConnect.AddData(data, db, hd);
      SqliteHelper.closeDb(db);
      Map map = {
        "id": returnId,
      };
      request.response.write(jsonEncode(map));
    }
  }

  ///Maybe doesn't have to implement
  static Future<void> DeleteData(io.HttpRequest request) async{
    
  }
}

class DataHelper{
  static String code = "code";
  static String id = "id";
}