import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

const clientId =
    '728569554138-t3v3sfuti8bc8bcci5qu63vekoivd4b1.apps.googleusercontent.com';
const clientSecret = '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';
const redirectUri = 'https://hendrilmendes.github.io/auth/';
const scope = 'https://www.googleapis.com/auth/blogger';

class OAuth2Helper {
  Future<String?> getAuthorizationCode() async {
    const authorizationUrl = 'https://accounts.google.com/o/oauth2/auth?'
        'client_id=$clientId&'
        'redirect_uri=$redirectUri&'
        'scope=$scope&'
        'response_type=code'; // Use "code" para o fluxo de autorização.

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authorizationUrl,
        callbackUrlScheme:
            'newsdroid', // Defina um esquema personalizado para a URL de retorno.
      );

      // A URL de retorno conterá o código de autorização como um parâmetro.
      final uri = Uri.parse(result);
      final authorizationCode = uri.queryParameters['code'];

      return authorizationCode;
    } catch (e) {
      // Lida com erros de autenticação.
      if (kDebugMode) {
        print('Erro de autenticação: $e');
      }
      return null;
    }
  }

  Future<String?> getAccessToken(String authorizationCode) async {
    final body = {
      'client_id': clientId,
      'client_secret': clientSecret,
      'redirect_uri': redirectUri,
      'grant_type': 'authorization_code',
      'scope': scope,
      'code': authorizationCode,
    };

    final response = await http.post(
      Uri.parse('https://accounts.google.com/o/oauth2/token'),
      body: body,
    );

    if (response.statusCode == 200) {
      final tokenData = json.decode(response.body);
      final accessToken = tokenData['access_token'];
      return accessToken;
    } else {
      if (kDebugMode) {
        print('Erro ao obter o token de acesso: ${response.body}');
      }
      return null;
    }
  }
}