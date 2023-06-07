import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  final String _firebaseToken = 'AIzaSyDfxqwZz2mUi-HnJJ1PMvmj7ufzF-N7M7Y';
  //este es el lugar seguro para guardar el token
  final storage = const FlutterSecureStorage();
  // si retorna algo, es un error, sino?, todo piola
  Future<String?> createUser(String email, String password) async {
    //información del post
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    //información del url sacada de Postman
    final url =
        Uri.https(_baseUrl, '/v1/accounts:signUp', {'key': _firebaseToken});
    //dispara la petición htpp
    final resp = await http.post(url, body: json.encode(authData));
    //se decodifica
    final Map<String, dynamic> respuestaDecodificada = json.decode(resp.body);

    if (respuestaDecodificada.containsKey('idToken')) {
      //Token guardar en algun lado seguro
      await storage.write(
          key: 'token', value: respuestaDecodificada['idToken']);
      return null;
    } else {
      return respuestaDecodificada['error']['message'];
    }
  }

  Future<String?> login(String email, String password) async {
    //información del post
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    //información del url sacada de Postman
    final url = Uri.https(_baseUrl, '/v1/accounts:signInWithPassword', {'key': _firebaseToken});
    //dispara la petición htpp
    final resp = await http.post(url, body: json.encode(authData));
    //se decodifica
    final Map<String, dynamic> respuestaDecodificada = json.decode(resp.body);

    if (respuestaDecodificada.containsKey('idToken')) {
      //Token guardar en algun lado seguro
      await storage.write(
          key: 'token', value: respuestaDecodificada['idToken']);
      return null;
    } else {
      return respuestaDecodificada['error']['message'];
    }
  }

  Future logOut() async {
    await storage.delete(key: 'token');
    return;
  }

  Future<String> readToken() async {
     return await storage.read(
          key: 'token') ?? '';
  }
}
