import 'package:dio/dio.dart';
import 'storage.dart';
import 'package:go_router/go_router.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions option , RequestInterceptorHandler handler) {
    print("Requesting");
    return super.onRequest(option,handler);
  }

  @override
  void onResponse(Response response , ResponseInterceptorHandler handler) {
    print("Response");
    return super.onResponse(response,handler);
  }

  @override
  void onError(DioException err , ErrorInterceptorHandler handler) {
    print("Error");
    super.onError(err, handler);
  }
}

// Dio Client
class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://piyapon.sinothaitrade.com',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ))
  ..interceptors.add(DioInterceptor());

  static Dio get dio => _dio;
}