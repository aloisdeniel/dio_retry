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

#### Global caching options

```dart
final dio = Dio()
  ..interceptors.add(CacheInterceptor(
    options: const CacheInterceptorRequestExtra(
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
  ..interceptors.add(CacheInterceptor(logger: Logger("Retry")));
```

## Availables stores

| name | description |
| --- | --- |
| [MemoryCacheStore](https://pub.dartlang.org/documentation/dio_cache/latest/dio_cache/MemoryCacheStore-class.html) | Stores all cached responses in a map in memory |
| [FileCacheStore](https://pub.dartlang.org/documentation/dio_cache/latest/dio_cache/FileCacheStore-class.html) | Stores each request in a dedicated file |
| [BackupCacheStore](https://pub.dartlang.org/documentation/dio_cache/latest/dio_cache/BackupCacheStore-class.html) | Reads values primarly from memory and backup values to specified store (ex: a FileCacheStore) |
| [FilteredCacheStore](https://pub.dartlang.org/documentation/dio_cache/latest/dio_cache/FilteredCacheStore-class.html) | Ignoring responses for save |

## Features and bugs

Please file issues.
