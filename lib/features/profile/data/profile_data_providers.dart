import 'package:avalanche/core/database/database_provider.dart';
import 'package:avalanche/core/directories/directories_provider.dart';
import 'package:avalanche/core/http_client/http_client_provider.dart';
import 'package:avalanche/features/config_option/data/config_option_data_providers.dart';
import 'package:avalanche/features/config_option/notifier/config_option_notifier.dart';
import 'package:avalanche/features/profile/data/profile_data_source.dart';
import 'package:avalanche/features/profile/data/profile_path_resolver.dart';
import 'package:avalanche/features/profile/data/profile_repository.dart';
import 'package:avalanche/singbox/service/singbox_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_data_providers.g.dart';

@Riverpod(keepAlive: true)
Future<ProfileRepository> profileRepository(ProfileRepositoryRef ref) async {
  final repo = ProfileRepositoryImpl(
    profileDataSource: ref.watch(profileDataSourceProvider),
    profilePathResolver: ref.watch(profilePathResolverProvider),
    singbox: ref.watch(singboxServiceProvider),
    configOptionRepository: ref.watch(configOptionRepositoryProvider),
    httpClient: ref.watch(httpClientProvider),
  );
  await repo.init().getOrElse((l) => throw l).run();
  return repo;
}

@Riverpod(keepAlive: true)
ProfileDataSource profileDataSource(ProfileDataSourceRef ref) {
  return ProfileDao(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
ProfilePathResolver profilePathResolver(ProfilePathResolverRef ref) {
  return ProfilePathResolver(
    ref.watch(appDirectoriesProvider).requireValue.workingDir,
  );
}
