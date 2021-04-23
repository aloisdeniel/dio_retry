import 'dart:async';
import 'package:dio/dio.dart';

typedef RetryEvaluator = FutureOr<bool> Function(DioError error);

class RetryOptions {
  /// The number of retry in case of an error
  final int retries;

  /// The interval before a retry.
  final Duration retryInterval;

  /// Evaluating if a retry is necessary.regarding the error.
  ///
  /// It can be a good candidate for additional operations too, like
  /// updating authentication token in case of a unauthorized error (be careful
  /// with concurrency though).
  ///
  /// Defaults to [defaultRetryEvaluator].
  RetryEvaluator get retryEvaluator => _retryEvaluator ?? defaultRetryEvaluator;

  final RetryEvaluator? _retryEvaluator;

  const RetryOptions({this.retries = 3, RetryEvaluator? retryEvaluator, this.retryInterval = const Duration(seconds: 1)}) : _retryEvaluator = retryEvaluator;

  factory RetryOptions.noRetry() {
    return RetryOptions(retries: 0);
  }

  static const extraKey = 'cache_retry_request';

  /// Returns [true] only if the response hasn't been cancelled or got
  /// a bas status code.
  static FutureOr<bool> defaultRetryEvaluator(DioError error) {
    return error.type != DioErrorType.cancel && error.type != DioErrorType.response;
  }

  static RetryOptions? fromExtra(RequestOptions request) {
    return request.extra[extraKey];
  }

  RetryOptions copyWith({int? retries, Duration? retryInterval}) {
    return RetryOptions(
      retries: retries ?? this.retries,
      retryInterval: retryInterval ?? this.retryInterval,
    );
  }

  Map<String, dynamic> toExtra() {
    return {extraKey: this};
  }

  Options toOptions() {
    return Options(extra: toExtra());
  }

  Options mergeIn(Options options) {
    return options.copyWith(extra: <String, dynamic>{}..addAll(options.extra ?? {})..addAll(toExtra()));
  }
}
