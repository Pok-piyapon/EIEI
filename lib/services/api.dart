import 'package:dio/dio.dart';

class ApiExternal {
  static Dio? _dio;

  static Dio getDioInstance() {
    // Create the Dio instance if not created yet
    if (_dio == null) {
      final options = BaseOptions(
        baseUrl: 'https://c.webservicehouse.com/Api',  // Set your base URL here
      );

      _dio = Dio(options);
    }

    return _dio!;
  }
}