import 'package:dio/dio.dart';
import 'package:dio_retry/dio_retry.dart';
import 'package:logging/logging.dart';

main() async {
  // Displaying logs
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final dio = Dio();

  // Add the interceptor with optional options
  dio.interceptors.add(RetryInterceptor(
    dio: dio,
    logger: Logger("Retry"),
    options: const RetryOptions(
      retryInterval: const Duration(seconds: 5),
    ),
  ));

  /// Sending a failing request for 3 times with a 5s interval
  try {
    await dio.get("http://www.mqldkfjmdisljfmlksqdjfmlkj.dev");
  } catch (e) {
    print("End error : $e");
  }
}
