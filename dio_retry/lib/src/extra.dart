import 'package:dio/dio.dart';

class RetryInterceptorRequestExtra {
  /// The number of retry in case of an error
  final int retries;

  // The interval before a retry.
  final Duration retryInterval;

  const RetryInterceptorRequestExtra(
      {this.retries = 3, this.retryInterval = const Duration(seconds: 1)})
      : assert(retries != null),
        assert(retryInterval != null);

  factory RetryInterceptorRequestExtra.noRetry() {
    return RetryInterceptorRequestExtra(
      retries: 0,
    );
  }

  static const extraKey = "cache_retry_request";

  factory RetryInterceptorRequestExtra.fromExtra(RequestOptions request) {
    return request.extra[extraKey];
  }

  RetryInterceptorRequestExtra copyWith({ 
    int retries,
    Duration retryInterval,
  }) => RetryInterceptorRequestExtra(
    retries: retries ?? this.retries,
    retryInterval: retryInterval ?? this.retryInterval,
  );

  Map<String, dynamic> toExtra() {
    return {
      extraKey: this,
    };
  }
}
