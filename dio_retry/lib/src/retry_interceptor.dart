import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import 'options.dart';

/// An interceptor that will try to send failed request again
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final Logger? _logger;
  final RetryOptions _options;

  RetryInterceptor({required Dio dio, Logger? logger, RetryOptions? options})
      : _options = options ?? const RetryOptions(),
        _dio = dio,
        _logger = logger;

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    var extra = RetryOptions.fromExtra(err.requestOptions) ?? _options;

    var shouldRetry = extra.retries > 0 && await _options.retryEvaluator(err);
    if (!shouldRetry) {
      return super.onError(err, handler);
    }

    if (extra.retryInterval.inMilliseconds > 0) {
      await Future.delayed(extra.retryInterval);
    }

    // Update options to decrease retry count before new try
    extra = extra.copyWith(retries: extra.retries - 1);
    err.requestOptions.extra = err.requestOptions.extra..addAll(extra.toExtra());

    _logger?.warning('[${err.requestOptions.uri}] An error occurred during request, trying a again (remaining tries: ${extra.retries}, error: ${err.error})');
    // We retry with the updated options
    await _dio
        .request(
          err.requestOptions.path,
          cancelToken: err.requestOptions.cancelToken,
          data: err.requestOptions.data,
          onReceiveProgress: err.requestOptions.onReceiveProgress,
          onSendProgress: err.requestOptions.onSendProgress,
          queryParameters: err.requestOptions.queryParameters,
          options: err.requestOptions.toOptions(),
        )
        .then((value) => handler.resolve(value), onError: (error) => handler.reject(error));
  }
}
