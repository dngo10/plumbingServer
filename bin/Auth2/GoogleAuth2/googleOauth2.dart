import 'dart:convert';
import 'dart:io';

class GoogleOauth2{
  File file = new File('bin/Auth2/GooglAuth2/data.jsonsdf');
  Map data;

  GoogleOauth2(){    
  }

  Future<void> init(){
    file.readAsString().then((fileContents) => json.decode(fileContents));
    
  }

}