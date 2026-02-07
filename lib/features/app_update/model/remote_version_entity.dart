import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:avalanche/core/model/environment.dart';

part 'remote_version_entity.freezed.dart';

@Freezed()
class RemoteVersionEntity with _$RemoteVersionEntity {
  const RemoteVersionEntity._();

  const factory RemoteVersionEntity({
    required String version,
    required String buildNumber,
    required String releaseTag,
    required bool preRelease,
    required String url,
    required DateTime publishedAt,
    required Environment flavor,
  }) = _RemoteVersionEntity;

  String get presentVersion =>
      flavor == Environment.prod ? version : "$version ${flavor.name}";
  
  /// Alias for url field - provides the download URL for the update
  String? get downloadUrl => url.isNotEmpty ? url : null;
}
