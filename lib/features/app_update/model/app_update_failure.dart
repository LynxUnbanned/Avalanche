import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:avalanche/core/localization/translations.dart';
import 'package:avalanche/core/model/failures.dart';

part 'app_update_failure.freezed.dart';

@freezed
sealed class AppUpdateFailure with _$AppUpdateFailure, Failure {
  const AppUpdateFailure._();

  @With<UnexpectedFailure>()
  const factory AppUpdateFailure.unexpected([
    Object? error,
    StackTrace? stackTrace,
  ]) = AppUpdateUnexpectedFailure;

  @override
  ({String type, String? message}) present(TranslationsEn t) {
    return switch (this) {
      AppUpdateUnexpectedFailure() => (
          type: t.failure.unexpected,
          message: null,
        ),
    };
  }
}
