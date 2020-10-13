import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';

class SqliteHelper{
    static const String _onWindows = "sqlite3.dll";
    
    static String _database = "/home/ubuntu/server/gouvis.db";

    static Database openDb(){
      if(Platform.isWindows){
        open.overrideForAll(_openSqlite);
        _database = "gouvis.db";
      }
      
      return sqlite3.open(_database);
    }

    static Future<void> closeDb(Database db) async{
      await db.dispose();
    }

    static DynamicLibrary _openSqlite(){
    String _sqliteString = "";
    if(Platform.isWindows){
      _sqliteString = _onWindows;
    }
    final libraryNextToScript = File(_sqliteString);
    return DynamicLibrary.open(libraryNextToScript.path);
  }
}