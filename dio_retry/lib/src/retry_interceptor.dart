import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import 'options.dart';

/// An interceptor that will try to send failed request again
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Logger? logger;
  final RetryOptions options;

  RetryInterceptor({required this.dio, this.logger, RetryOptions? options}) : options = options ?? const RetryOptions();

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    var extra = RetryOptions.fromExtra(err.requestOptions) ?? options;

    final shouldRetry = extra.retries > 0 && await options.retryEvaluator(err);
    if (!shouldRetry) {
      return super.onError(err, handler);
    }

    if (extra.retryInterval.inMilliseconds > 0) {
      await Future.delayed(extra.retryInterval);
    }

    // Update options to decrease retry count before new try
    extra = extra.copyWith(retries: extra.retries - 1);
    err.requestOptions.extra = err.requestOptions.extra..addAll(extra.toExtra());

    try {
      logger?.warning('[${err.requestOptions.uri}] An error occurred during request, trying a again (remaining tries: ${extra.retries}, error: ${err.error})');
      // We retry with the updated options
      return await dio.request(
        err.requestOptions.path,
        cancelToken: err.requestOptions.cancelToken,
        data: err.requestOptions.data,
        onReceiveProgress: err.requestOptions.onReceiveProgress,
        onSendProgress: err.requestOptions.onSendProgress,
        queryParameters: err.requestOptions.queryParameters,
        options: toOptions(err.requestOptions),
      );
    } catch (e) {
      return e;
    }
  }

  Options toOptions(RequestOptions o) {
    return Options(
      method: o.method,
      sendTimeout: o.sendTimeout,
      receiveTimeout: o.receiveTimeout,
      extra: o.extra,
      headers: o.headers,
      responseType: o.responseType,
      contentType: o.contentType,
      validateStatus: o.validateStatus,
      receiveDataWhenStatusError: o.receiveDataWhenStatusError,
      followRedirects: o.followRedirects,
      maxRedirects: o.maxRedirects,
      requestEncoder: o.requestEncoder,
      responseDecoder: o.responseDecoder,
      listFormat: o.listFormat,
    );
  }
}
