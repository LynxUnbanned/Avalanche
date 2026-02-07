import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:avalanche/core/app_info/app_info_provider.dart';
import 'package:avalanche/core/localization/translations.dart';
import 'package:avalanche/core/model/failures.dart';
import 'package:avalanche/core/router/router.dart';
import 'package:avalanche/core/theme/glassmorphism.dart';
import 'package:avalanche/features/home/widget/connection_button.dart';
import 'package:avalanche/features/home/widget/empty_profiles_home_body.dart';
import 'package:avalanche/features/home/widget/quick_connect_button.dart';
import 'package:avalanche/features/home/widget/world_map_widget.dart';
import 'package:avalanche/features/profile/notifier/active_profile_notifier.dart';
import 'package:avalanche/features/profile/widget/profile_tile.dart';
import 'package:avalanche/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:avalanche/features/proxy/active/active_proxy_footer.dart';
import 'package:avalanche/features/proxy/model/server_location.dart';
import 'package:avalanche/features/proxy/overview/proxies_overview_notifier.dart';
import 'package:avalanche/features/connection/notifier/connection_notifier.dart';
import 'package:avalanche/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final hasAnyProfile = ref.watch(hasAnyProfileProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final asyncProxies = ref.watch(proxiesOverviewNotifierProvider);
    final connectionStatus = ref.watch(connectionNotifierProvider);
    final glassTheme = Theme.of(context).extension<GlassmorphismTheme>()!;
    final theme = Theme.of(context);

    // Convert proxy data to map server data
    final mapServers = <MapServerData>[];
    if (asyncProxies case AsyncData(value: final groups)) {
      for (final group in groups) {
        for (final proxy in group.items) {
          if (!proxy.isVisible) continue;
          final countryCode = _extractCountryCode(proxy.name);
          if (countryCode != null && countryCoordinates.containsKey(countryCode)) {
            mapServers.add(MapServerData(
              id: proxy.tag,
              name: proxy.name,
              countryCode: countryCode,
              delay: proxy.urlTestDelay > 0 ? proxy.urlTestDelay : null,
            ));
          }
        }
      }
    }

    // Determine if connected
    final isConnected = connectionStatus.maybeWhen(
      data: (status) => status.isConnected,
      orElse: () => false,
    );

    // Get selected proxy tag for connection indicator
    String? selectedProxyId;
    if (asyncProxies case AsyncData(value: final groups)) {
      for (final group in groups) {
        if (group.selected.isNotEmpty) {
          selectedProxyId = group.selected;
          break;
        }
      }
    }

    // Find best server (lowest latency) for Quick Connect
    MapServerData? bestServer;
    int? bestLatency;
    for (final server in mapServers) {
      if (server.delay != null && server.delay! > 0) {
        if (bestLatency == null || server.delay! < bestLatency) {
          bestLatency = server.delay;
          bestServer = server;
        }
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          const GradientBackground(),

          // Main content
          switch (activeProfile) {
            AsyncData(value: final profile?) => Column(
                children: [
                  // Frosted app bar
                  _FrostedAppBar(t: t, glassTheme: glassTheme, theme: theme),

                  // Profile tile
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: FrostedCard(
                      child: ProfileTile(profile: profile, isMain: true),
                    ),
                  ),

                  // World map
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: mapServers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const ConnectionButton(),
                                  const SizedBox(height: 16),
                                  const ActiveProxyDelayIndicator(),
                                ],
                              ),
                            )
                          : WorldMapWidget(
                              servers: mapServers,
                              onServerSelected: (server) {
                                // Get the group tag and select this proxy
                                if (asyncProxies case AsyncData(value: final groups)) {
                                  for (final group in groups) {
                                    if (group.items.any((p) => p.tag == server.id)) {
                                      ref.read(proxiesOverviewNotifierProvider.notifier)
                                          .changeProxy(group.tag, server.id);
                                      break;
                                    }
                                  }
                                }
                              },
                              connectedServerId: isConnected ? selectedProxyId : null,
                            ),
                    ),
                  ),

                  // Connection button overlay
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ConnectionButton(),
                        const SizedBox(height: 8),
                        const ActiveProxyDelayIndicator(),
                      ],
                    ),
                  ),

                  // Footer on narrow screens
                  if (MediaQuery.sizeOf(context).width < 840)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ActiveProxyFooter(),
                    ),
                ],
              ),
            AsyncData() => switch (hasAnyProfile) {
                AsyncData(value: true) => Column(
                    children: [
                      _FrostedAppBar(t: t, glassTheme: glassTheme, theme: theme),
                      const Expanded(child: EmptyActiveProfileHomeBody()),
                    ],
                  ),
                _ => Column(
                    children: [
                      _FrostedAppBar(t: t, glassTheme: glassTheme, theme: theme),
                      const Expanded(child: EmptyProfilesHomeBody()),
                    ],
                  ),
              },
            AsyncError(:final error) => Column(
                children: [
                  _FrostedAppBar(t: t, glassTheme: glassTheme, theme: theme),
                  Expanded(
                    child: Center(
                      child: Text(t.presentShortError(error)),
                    ),
                  ),
                ],
              ),
            _ => Column(
                children: [
                  _FrostedAppBar(t: t, glassTheme: glassTheme, theme: theme),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
          },

          // Quick Connect floating button overlay
          if (mapServers.isNotEmpty && bestServer != null)
            QuickConnectOverlay(
              onQuickConnect: () {
                if (asyncProxies case AsyncData(value: final groups)) {
                  // Select best server and connect
                  for (final group in groups) {
                    if (group.items.any((p) => p.tag == bestServer!.id)) {
                      ref.read(proxiesOverviewNotifierProvider.notifier)
                          .changeProxy(group.tag, bestServer!.id);
                      // Toggle connection if not connected
                      if (!isConnected) {
                        ref.read(connectionNotifierProvider.notifier)
                            .toggleConnection();
                      }
                      break;
                    }
                  }
                }
              },
              isConnected: isConnected,
              bestServerName: bestServer.name,
              bestServerLatency: bestLatency,
            ),
        ],
      ),
    );
  }

  /// Extract country code from proxy name
  /// Supports formats like:
  /// - "🇺🇸 US Server" → "US"
  /// - "United States - NYC" → "US"
  /// - "[US] New York" → "US"
  /// - "US_Server_01" → "US"
  String? _extractCountryCode(String name) {
    // First, check for flag emoji and extract country from it
    final flagRegex = RegExp(r'[\u{1F1E6}-\u{1F1FF}]{2}', unicode: true);
    final flagMatch = flagRegex.firstMatch(name);
    if (flagMatch != null) {
      final flag = flagMatch.group(0)!;
      final code = _flagToCountryCode(flag);
      if (code != null) return code;
    }

    // Check for country codes in brackets/parentheses
    final bracketRegex = RegExp(r'[\[\(]([A-Z]{2})[\]\)]');
    final bracketMatch = bracketRegex.firstMatch(name.toUpperCase());
    if (bracketMatch != null) {
      return bracketMatch.group(1);
    }

    // Check for known country names
    final nameLower = name.toLowerCase();
    for (final entry in _countryNameToCode.entries) {
      if (nameLower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Check for country code prefix (e.g., "US-Server")
    final prefixRegex = RegExp(r'^([A-Z]{2})[_\-\s]');
    final prefixMatch = prefixRegex.firstMatch(name.toUpperCase());
    if (prefixMatch != null) {
      final code = prefixMatch.group(1);
      if (countryCoordinates.containsKey(code)) return code;
    }

    return null;
  }

  String? _flagToCountryCode(String flag) {
    if (flag.length != 4) return null;
    final runes = flag.runes.toList();
    if (runes.length != 2) return null;
    final first = String.fromCharCode(runes[0] - 0x1F1E6 + 65);
    final second = String.fromCharCode(runes[1] - 0x1F1E6 + 65);
    return '$first$second';
  }
}

/// Map of common country names/cities to country codes
const _countryNameToCode = {
  'united states': 'US',
  'usa': 'US',
  'america': 'US',
  'new york': 'US',
  'los angeles': 'US',
  'chicago': 'US',
  'seattle': 'US',
  'miami': 'US',
  'dallas': 'US',
  'united kingdom': 'GB',
  'uk': 'GB',
  'london': 'GB',
  'germany': 'DE',
  'frankfurt': 'DE',
  'berlin': 'DE',
  'france': 'FR',
  'paris': 'FR',
  'netherlands': 'NL',
  'amsterdam': 'NL',
  'japan': 'JP',
  'tokyo': 'JP',
  'singapore': 'SG',
  'hong kong': 'HK',
  'south korea': 'KR',
  'korea': 'KR',
  'seoul': 'KR',
  'canada': 'CA',
  'toronto': 'CA',
  'vancouver': 'CA',
  'australia': 'AU',
  'sydney': 'AU',
  'melbourne': 'AU',
  'india': 'IN',
  'mumbai': 'IN',
  'brazil': 'BR',
  'sao paulo': 'BR',
  'russia': 'RU',
  'moscow': 'RU',
  'china': 'CN',
  'taiwan': 'TW',
  'ireland': 'IE',
  'dubai': 'AE',
  'turkey': 'TR',
  'istanbul': 'TR',
  'sweden': 'SE',
  'switzerland': 'CH',
  'poland': 'PL',
  'italy': 'IT',
  'spain': 'ES',
};

class _FrostedAppBar extends StatelessWidget {
  const _FrostedAppBar({
    required this.t,
    required this.glassTheme,
    required this.theme,
  });

  final TranslationsEn t;
  final GlassmorphismTheme glassTheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return FrostedContainer(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
      ),
      borderRadius: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: t.general.appTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const TextSpan(text: " "),
                const WidgetSpan(
                  child: AppVersionLabel(),
                  alignment: PlaceholderAlignment.middle,
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => const QuickSettingsRoute().push(context),
            icon: const Icon(FluentIcons.options_24_filled),
            tooltip: t.config.quickSettings,
          ),
          IconButton(
            onPressed: () => const AddProfileRoute().push(context),
            icon: const Icon(FluentIcons.add_circle_24_filled),
            tooltip: t.profile.add.buttonText,
          ),
        ],
      ),
    );
  }
}

class AppVersionLabel extends HookConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final theme = Theme.of(context);

    final version = ref.watch(appInfoProvider).requireValue.presentVersion;
    if (version.isBlank) return const SizedBox();

    return Semantics(
      label: t.about.version,
      button: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withOpacity(0.6),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 1,
        ),
        child: Text(
          version,
          textDirection: TextDirection.ltr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
