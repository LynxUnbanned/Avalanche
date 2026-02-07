import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:avalanche/core/localization/translations.dart';
import 'package:avalanche/core/router/routes.dart';
import 'package:avalanche/core/theme/avalanche_theme.dart';
import 'package:avalanche/core/widget/frosted_container.dart';
import 'package:avalanche/features/common/nested_app_bar.dart';
import 'package:avalanche/features/proxy/overview/proxies_overview_notifier.dart';
import 'package:avalanche/features/settings/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Unified Settings page combining the old Proxies, Config Options, Logs, 
/// and Settings pages into a single consolidated view.
class SettingsOverviewPage extends HookConsumerWidget {
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          NestedAppBar(
            title: Text(t.settings.pageTitle),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList.list(
              children: [
                // ═══════════════════════════════════════════════════════════
                // Connection Section
                // ═══════════════════════════════════════════════════════════
                _SectionHeader(
                  icon: FluentIcons.plug_connected_20_filled,
                  title: 'Connection',
                ),
                const Gap(8),
                
                // Protocols Tile - Navigate to proxies/config
                _SettingsNavigationTile(
                  icon: FluentIcons.filter_20_filled,
                  title: t.proxies.pageTitle,
                  subtitle: 'Manage proxy configurations',
                  onTap: () => context.push(const ProxiesRoute().location),
                ),
                
                // Config Options Tile
                _SettingsNavigationTile(
                  icon: FluentIcons.box_edit_20_filled,
                  title: t.config.pageTitle,
                  subtitle: 'Protocol and routing options',
                  onTap: () => context.push(const ConfigOptionsRoute().location),
                ),
                
                // Test All Servers Tile
                _SettingsActionTile(
                  icon: FluentIcons.arrow_sync_circle_20_filled,
                  title: 'Test All Servers',
                  subtitle: 'Ping all servers to check latency',
                  onTap: () async {
                    // Trigger URL test on all proxy groups
                    final notifier = ref.read(proxiesOverviewNotifierProvider.notifier);
                    final groups = ref.read(proxiesOverviewNotifierProvider).valueOrNull ?? [];
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Testing all servers...')),
                    );
                    
                    for (final group in groups) {
                      await notifier.urlTest(group.tag);
                    }
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Server tests complete!')),
                      );
                    }
                  },
                ),
                
                const Gap(24),
                
                // ═══════════════════════════════════════════════════════════
                // Data Section
                // ═══════════════════════════════════════════════════════════
                _SectionHeader(
                  icon: FluentIcons.database_20_filled,
                  title: 'Data',
                ),
                const Gap(8),
                
                // Logs Tile
                _SettingsNavigationTile(
                  icon: FluentIcons.document_text_20_filled,
                  title: t.logs.pageTitle,
                  subtitle: 'View connection logs',
                  onTap: () => context.push(const LogsOverviewRoute().location),
                ),
                
                // Speedtest Tile
                _SettingsNavigationTile(
                  icon: FluentIcons.top_speed_20_filled,
                  title: 'Speed Test',
                  subtitle: 'Test your connection speed',
                  onTap: () {
                    // TODO: Implement speedtest functionality
                    _showSpeedtestDialog(context);
                  },
                ),
                
                const Gap(24),
                
                // ═══════════════════════════════════════════════════════════
                // General Settings Section
                // ═══════════════════════════════════════════════════════════
                _SectionHeader(
                  icon: FluentIcons.settings_20_filled,
                  title: t.settings.general.sectionTitle,
                ),
                const Gap(8),
                
                // Standard setting tiles
                const GeneralSettingTiles(),
                const PlatformSettingsTiles(),
                
                const Gap(24),
                
                // ═══════════════════════════════════════════════════════════
                // Advanced Settings Section
                // ═══════════════════════════════════════════════════════════
                _SectionHeader(
                  icon: FluentIcons.wrench_20_filled,
                  title: t.settings.advanced.sectionTitle,
                ),
                const Gap(8),
                
                const AdvancedSettingTiles(),
                
                const Gap(24),
                
                // ═══════════════════════════════════════════════════════════
                // About Section
                // ═══════════════════════════════════════════════════════════
                _SectionHeader(
                  icon: FluentIcons.info_20_filled,
                  title: t.about.pageTitle,
                ),
                const Gap(8),
                
                // About Tile
                _SettingsNavigationTile(
                  icon: FluentIcons.info_20_filled,
                  title: 'About Avalanche',
                  subtitle: 'Version, licenses, and more',
                  onTap: () => context.push(const AboutRoute().location),
                ),
                
                const Gap(32),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showSpeedtestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(FluentIcons.top_speed_20_filled),
            Gap(8),
            Text('Speed Test'),
          ],
        ),
        content: const Text(
          'This will open Ookla Speedtest in your browser to measure your connection speed.\n\n'
          'Make sure you are connected to a server for accurate results.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Launch Ookla Speedtest
              final uri = Uri.parse('https://www.speedtest.net');
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open speedtest'),
                    ),
                  );
                }
              }
            },
            child: const Text('Open Speedtest'),
          ),
        ],
      ),
    );
  }
}

/// Section header with icon and title
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });
  
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AvalancheTheme.iceBlue,
        ),
        const Gap(8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AvalancheTheme.iceBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Navigation tile for accessing sub-pages
class _SettingsNavigationTile extends StatelessWidget {
  const _SettingsNavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FrostedContainer(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AvalancheTheme.iceBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AvalancheTheme.iceBlue,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AvalancheTheme.frostWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AvalancheTheme.frostWhite.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  FluentIcons.chevron_right_20_regular,
                  size: 20,
                  color: AvalancheTheme.frostWhite.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Action tile for in-place actions (not navigation)
class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FrostedContainer(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AvalancheTheme.auroraGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AvalancheTheme.auroraGreen,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AvalancheTheme.frostWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AvalancheTheme.frostWhite.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  FluentIcons.play_circle_20_regular,
                  size: 20,
                  color: AvalancheTheme.auroraGreen.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
