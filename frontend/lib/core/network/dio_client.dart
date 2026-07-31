import 'package:dio/dio.dart';

import '../services/storage_service.dart';


class DioClient {

  static final Dio dio = Dio(

    BaseOptions(

      connectTimeout: const Duration(
        seconds: 10,
      ),

      receiveTimeout: const Duration(
        seconds: 10,
      ),

      headers: {
        "Content-Type": "application/json",
      },

    ),

  )..interceptors.add(

      InterceptorsWrapper(

        onRequest: (
          options,
          handler,
        ) async {


          final token =
              await StorageService.getToken();


          print("========== API REQUEST ==========");
          print("URL: ${options.uri}");
          print("TOKEN: $token");


          if (token != null && token.isNotEmpty) {

            options.headers["Authorization"] =
                "Bearer $token";

          }


          print(
            "HEADERS: ${options.headers}",
          );


          handler.next(options);

        },


        onError: (
          DioException error,
          handler,
        ) {


          print("========== API ERROR ==========");
          print(
            "STATUS: ${error.response?.statusCode}",
          );

          print(
            "DATA: ${error.response?.data}",
          );

          print(
            "MESSAGE: ${error.message}",
          );


          handler.next(error);

        },

      ),

    );

}