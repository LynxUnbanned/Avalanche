import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:avalanche/core/app_info/app_info_provider.dart';
import 'package:avalanche/core/localization/locale_preferences.dart';
import 'package:avalanche/core/model/constants.dart';
import 'package:avalanche/core/preferences/preferences_provider.dart';
import 'package:avalanche/core/utils/preferences_utils.dart';
import 'package:avalanche/features/app_update/data/app_update_data_providers.dart';
import 'package:avalanche/features/app_update/model/app_update_failure.dart';
import 'package:avalanche/features/app_update/model/remote_version_entity.dart';
import 'package:avalanche/features/app_update/notifier/app_update_state.dart';
import 'package:avalanche/features/connection/notifier/connection_notifier.dart';
import 'package:avalanche/features/connection/model/connection_status.dart';
import 'package:avalanche/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version/version.dart';
import 'package:http/http.dart' as http;

part 'app_update_notifier.g.dart';

const _debugUpgrader = true;

/// Check for updates every 6 hours
const _checkInterval = Duration(hours: 6);

@riverpod
Upgrader upgrader(UpgraderRef ref) => Upgrader(
      appcastConfig: AppcastConfiguration(url: Constants.appCastUrl),
      debugLogging: _debugUpgrader && kDebugMode,
      durationUntilAlertAgain: const Duration(hours: 12),
      messages: UpgraderMessages(
        code: ref.watch(localePreferencesProvider).languageCode,
      ),
    );

@Riverpod(keepAlive: true)
class AppUpdateNotifier extends _$AppUpdateNotifier with AppLogger {
  Timer? _periodicTimer;
  
  @override
  AppUpdateState build() {
    // Set up periodic update check
    _schedulePeriodicCheck();
    
    // Clean up timer on dispose
    ref.onDispose(() {
      _periodicTimer?.cancel();
    });
    
    return const AppUpdateState.initial();
  }

  void _schedulePeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_checkInterval, (_) async {
      loggy.debug("Periodic update check triggered");
      await check();
    });
    
    // Also check on startup after a short delay
    Future.delayed(const Duration(seconds: 30), () async {
      if (state is AppUpdateStateInitial) {
        loggy.debug("Initial startup update check");
        await check();
      }
    });
  }

  PreferencesEntry<String?, dynamic> get _ignoreReleasePref => PreferencesEntry(
        preferences: ref.read(sharedPreferencesProvider).requireValue,
        key: 'ignored_release_version',
        defaultValue: null,
      );

  PreferencesEntry<String?, dynamic> get _lastCheckPref => PreferencesEntry(
        preferences: ref.read(sharedPreferencesProvider).requireValue,
        key: 'last_update_check',
        defaultValue: null,
      );

  Future<AppUpdateState> check() async {
    loggy.debug("checking for update");
    state = const AppUpdateState.checking();
    final appInfo = ref.watch(appInfoProvider).requireValue;
    if (!appInfo.release.allowCustomUpdateChecker) {
      loggy.debug(
        "custom update checkers are not allowed for [${appInfo.release.name}] release",
      );
      return state = const AppUpdateState.disabled();
    }
    
    // Record check time
    await _lastCheckPref.write(DateTime.now().toIso8601String());
    
    return ref.watch(appUpdateRepositoryProvider).getLatestVersion().match(
      (err) {
        loggy.warning("failed to get latest version", err);
        return state = AppUpdateState.error(err);
      },
      (remote) {
        try {
          final latestVersion = Version.parse(remote.version);
          final currentVersion = Version.parse(appInfo.version);
          if (latestVersion > currentVersion) {
            if (remote.version == _ignoreReleasePref.read()) {
              loggy.debug("ignored release [${remote.version}]");
              return state = AppUpdateStateIgnored(remote);
            }
            loggy.debug("new version available: $remote");
            
            // Auto-download if disconnected
            _checkAutoDownload(remote);
            
            return state = AppUpdateState.available(remote);
          }
          loggy.info(
            "already using latest version[$currentVersion], remote: [${remote.version}]",
          );
          return state = const AppUpdateState.notAvailable();
        } catch (error, stackTrace) {
          loggy.warning("error parsing versions", error, stackTrace);
          return state = AppUpdateState.error(
            AppUpdateFailure.unexpected(error, stackTrace),
          );
        }
      },
    ).run();
  }

  Future<void> _checkAutoDownload(RemoteVersionEntity version) async {
    try {
      final connectionStatus = await ref.read(connectionNotifierProvider.future);
      if (connectionStatus is Disconnected) {
        loggy.debug("VPN disconnected, auto-downloading update...");
        await downloadUpdate(version);
      } else {
        loggy.debug("VPN connected, skipping auto-download");
      }
    } catch (e) {
      loggy.warning("Error checking connection status for auto-download", e);
    }
  }

  Future<void> downloadUpdate(RemoteVersionEntity version) async {
    if (version.downloadUrl == null) {
      loggy.warning("No download URL available for version ${version.version}");
      return;
    }
    
    try {
      state = AppUpdateState.downloading(versionInfo: version, progress: 0.0);
      
      final tempDir = await getTemporaryDirectory();
      final fileName = "Avalanche-${version.version}.dmg"; 
      final filePath = path.join(tempDir.path, fileName);
      
      loggy.debug("Downloading update to: $filePath");
      
      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(version.downloadUrl!));
        final response = await client.send(request);
        
        if (response.statusCode != 200) {
          throw Exception('Failed to download: HTTP ${response.statusCode}');
        }
        
        final contentLength = response.contentLength ?? 0;
        var receivedBytes = 0;
        final sink = File(filePath).openWrite();
        
        await for (final chunk in response.stream) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          if (contentLength > 0) {
            final progress = receivedBytes / contentLength;
            state = AppUpdateState.downloading(versionInfo: version, progress: progress);
          }
        }
        
        await sink.close();
        
        loggy.info("Update downloaded successfully: $filePath");
        state = AppUpdateState.downloaded(versionInfo: version, filePath: filePath);
        
      } finally {
        client.close();
      }
    } catch (error, stackTrace) {
      loggy.warning("Failed to download update", error, stackTrace);
      state = AppUpdateState.error(AppUpdateFailure.unexpected(error, stackTrace));
    }
  }

  Future<void> installUpdate(String filePath) async {
    try {
      loggy.debug("Opening update installer: $filePath");
      // On macOS, open the DMG file
      if (Platform.isMacOS) {
        await Process.run('open', [filePath]);
      } else if (Platform.isWindows) {
        await Process.run('start', [filePath], runInShell: true);
      }
    } catch (error, stackTrace) {
      loggy.warning("Failed to open update installer", error, stackTrace);
    }
  }

  Future<void> ignoreRelease(RemoteVersionEntity version) async {
    loggy.debug("ignoring release [${version.version}]");
    await _ignoreReleasePref.write(version.version);
    state = AppUpdateStateIgnored(version);
  }

  /// Force a check regardless of last check time
  Future<void> forceCheck() async {
    loggy.debug("Force checking for update");
    await check();
  }
}
