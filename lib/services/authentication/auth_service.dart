import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final Dio _dio = Dio();

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
}
