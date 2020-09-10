
import 'dart:io' as io;
import 'microsoftOauth2.dart';

void handleAuth2(io.HttpRequest request, MicrosoftOAuth2 msAuth) async{
  await msAuth.getAccessToken(request);
}

void handleLogout(io.HttpRequest request, MicrosoftOAuth2 msAuth) async{
  await msAuth.logout(request);
}