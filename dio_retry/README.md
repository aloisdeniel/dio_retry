# dio_retry

A plugin for [dio](https://pub.dev/packages/dio) that retries failed requests.

## Usage

```dart
import 'package:dio_retry/dio_retry.dart';
```

#### Basic configuration

```dart
final dio = Dio()
  ..interceptors.add(RetryInterceptor());
```

#### Global retry options

```dart
final dio = Dio()
  ..interceptors.add(RetryInterceptor(
    options: const RetryInterceptorRequestExtra(
      retries: 3, // Number of retries before a failure
      retryInterval: const Duration(seconds: 1), // Interval between each retry
    )
  )
);
```

#### Sending a request with options

```dart
final response = await dio.get("http://www.flutter.dev", options: Options(
    extra: RetryInterceptorRequestExtra(
      retryInterval: const Duration(seconds: 10),
    ).toExtra(),
  ));
```


#### Sending a request without retry

```dart
final response = await dio.get("http://www.flutter.dev", options: Options(
    extra: RetryInterceptorRequestExtra.noRetry().toExtra(),
  ));
```

#### Logging retry operations

```dart
final dio = Dio()
  ..interceptors.add(RetryInterceptor(logger: Logger("Retry")));
```

## Features and bugs

Please file issues.
