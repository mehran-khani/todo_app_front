import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio();
  // Registration Logic
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String confirmPassword,
    String name,
  ) async {
    final registerUrl = dotenv.env['API_REGISTER_URL'];
    final response = await _dio.post(
      registerUrl!,
      data: {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'name': name,
      },
    );

    if (response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to register');
    }
  }

  // Login logics
  Future<Map<String, dynamic>> login(String email, String password) async {
    final loginUrl = dotenv.env['API_LOGIN_URL'];
    final response = await _dio.post(
      loginUrl!,
      data: {
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final refreshUrl = dotenv.env['API_REFRESH_URL'];
    final response = await _dio.post(
      refreshUrl!,
      data: {'refresh': refreshToken},
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> writeToken(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readToken(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAllTokens() async {
    await _storage.deleteAll();
  }
}
