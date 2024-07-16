import 'package:dio/dio.dart' as dio;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:to_do_application/models/user_model/user_model.dart';

class AuthService {
  final dio.Dio _dio = dio.Dio();
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
      //parse the user's data and all the other data from the response
      final user = UserModel.fromJson(response.data['user']);
      final message = response.data['message'];
      final access = response.data['access'];
      final refresh = response.data['refresh'];
      return {
        'message': message,
        'user': user,
        'access': access,
        'refresh': refresh,
      };
    } else {
      throw Exception('Failed to register');
    }
  }

  // resending verification email
  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    final resendUrl = dotenv.env['API_RESEND_VERIFICATION_URL'];
    final response = await _dio.post(
      resendUrl!,
      data: {'email': email},
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to resend verification email');
    }
  }

  // Login logics
  Future<Map<String, dynamic>> login(String email, String password) async {
    final loginUrl = dotenv.env['API_LOGIN_URL'];
    try {
      final response = await _dio.post(
        loginUrl!,
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        // do the same thing we did in register method
        final user = UserModel.fromJson(response.data['user']);
        final message = response.data['message'];
        final access = response.data['access'];
        final refresh = response.data['refresh'];
        return {
          'message': message,
          'user': user,
          'access': access,
          'refresh': refresh,
        };
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //get current user
  Future<UserModel> getCurrentUser(String accessToken) async {
    final getUserUrl = dotenv.env['API_GET_USER_URL'];
    try {
      final response = await _dio.get(
        getUserUrl!,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch current user');
      }
    } catch (e) {
      throw Exception('Error: $e');
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
