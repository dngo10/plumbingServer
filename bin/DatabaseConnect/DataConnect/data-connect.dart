import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';
import '../UserConnect/user-connect.dart';

class DataConnect{

  ///Add data to database, and getback the id;
  static int AddData(CommandData data, Database db, DataHeader header){
    if(UserConnect.HasUser(header.code, db)){
      if(data.id == null){
        String sql = "INSERT INTO ${CommandDataGoodie.info} ";
        sql += '(${CommandDataGoodie.command}, ';
        sql += '${CommandDataGoodie.date}, ';
        sql += '${CommandDataGoodie.data}) ';
        sql += 'VALUES (?, ?, ?)';
        db.prepare(sql).execute([
          data.command,
          data.date,
          data.data
        ]);
      }else{
        String sql = "UPDATE ${CommandDataGoodie.info} SET ";
        sql += '${CommandDataGoodie.command} = \"${data.command}\" , '; 
        sql += '${CommandDataGoodie.date} = \"${data.date.toString()}\", ';
        sql += '${CommandDataGoodie.data} = \"${data.data}\" ';
        sql += 'WHERE ${CommandDataGoodie.id} = ${data.id}';
        db.execute(sql);

        // Dispose DB always at the end of transaction...   
        db.dispose();
      }
      /// GET BACK THE ID;
      /// 
      int id = db.lastInsertRowId;
      return id;
    }
    // -1 NOT a valid data OR header.
    return -1;
  }


  static bool HasData(DataHeader header, Database db){
    if(UserConnect.HasUser(header.code, db)){
      String sql = "SELECT * FROM ${CommandDataGoodie.info} ";
            sql += "WHERE ${header.id} = ${CommandDataGoodie.id}";
      ResultSet resultSet = db.select(sql);
      if(resultSet.length == 1){
        return true;
      }
    }
    return false;
  }

  static CommandData GetData(DataHeader header, Database db){
    if(HasData(header, db)){ // HasData Already check whether there is a user or not
      String sql = "SELECT * FROM ${CommandDataGoodie.info} ";
            sql += "WHERE ${header.id} = ${CommandDataGoodie.id}";
      Row row = db.select(sql).first;
      CommandData data = CommandData();
      data.id = row[CommandDataGoodie.id];
      data.date = DateTime.parse(row[CommandDataGoodie.date]);
      data.data = row[CommandDataGoodie.data];
      data.command = row[CommandDataGoodie.command];
      return data;
    }
    return null;
  }

  static CommandData jsonToData(String json){
    Map map = jsonDecode(json);
    if(map.containsKey(CommandDataGoodie.data) &&
       map.containsKey(CommandDataGoodie.date) &&
       map.containsKey(CommandDataGoodie.command)){
         CommandData data = CommandData();
         data.command = map[CommandDataGoodie.command];
         data.data = map[CommandDataGoodie.data];
         data.date = DateTime.parse(map[CommandDataGoodie.date]);
          if(map.containsKey(CommandDataGoodie.id)){
            data.id = map[CommandDataGoodie.id];
          }
         return data;
    }
    return null;
  }
}

class CommandDataGoodie{
  static String info = "INFO"; // Table Name
  static String command = "COMMAND";  //COMMAND MUST BE SPECIFIED
  static String date = "DATE";  // String
  static String data = "DATA"; // json
  static String id = "ID";
}

class CommandData{
  int id;
  String command;
  String data; // basically it's json;
  DateTime date; //time created, using UTC format;

  String toJson(){
    Map<String,dynamic> result = {
      "id": id,
      "command": command,
      "data": data,
      "date": date.toString()
    };
    return jsonEncode(result);
  }
}


class DataHeader{
  int id; // For Adding data, you don't need id (cuz you can't have one);
  String code;
  static String idStr = "id";
  static String codeStr = "code";

  static DataHeader jsonToDataHeader(String json){
    Map map = jsonDecode(json);
    if(map.containsKey(idStr) &&
       map.containsKey(codeStr)
    ){
      DataHeader dh = DataHeader();
      dh.id = map[idStr];
      dh.code = map[codeStr];
      return dh;
    }
    return null;
  }
}
