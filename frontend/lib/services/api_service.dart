import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/api_constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<Response> get(String path) => _dio.get(path);

  Future<Response> post(String path, dynamic data) => _dio.post(path, data: data);

  Future<Response> patch(String path, dynamic data) => _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}
