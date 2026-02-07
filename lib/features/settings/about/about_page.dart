import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:avalanche/core/app_info/app_info_provider.dart';
import 'package:avalanche/core/directories/directories_provider.dart';
import 'package:avalanche/core/localization/translations.dart';
import 'package:avalanche/core/model/constants.dart';
import 'package:avalanche/core/model/failures.dart';
import 'package:avalanche/core/theme/avalanche_theme.dart';
import 'package:avalanche/core/widget/adaptive_icon.dart';
import 'package:avalanche/core/widget/frosted_container.dart';
import 'package:avalanche/features/app_update/notifier/app_update_notifier.dart';
import 'package:avalanche/features/app_update/notifier/app_update_state.dart';
import 'package:avalanche/features/app_update/widget/new_version_dialog.dart';
import 'package:avalanche/features/common/nested_app_bar.dart';
import 'package:avalanche/gen/assets.gen.dart';
import 'package:avalanche/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final appInfo = ref.watch(appInfoProvider).requireValue;
    final appUpdate = ref.watch(appUpdateNotifierProvider);

    ref.listen(
      appUpdateNotifierProvider,
      (_, next) async {
        if (!context.mounted) return;
        switch (next) {
          case AppUpdateStateAvailable(:final versionInfo) ||
                AppUpdateStateIgnored(:final versionInfo):
            return NewVersionDialog(
              appInfo.presentVersion,
              versionInfo,
              canIgnore: false,
            ).show(context);
          case AppUpdateStateError(:final error):
            return CustomToast.error(t.presentShortError(error)).show(context);
          case AppUpdateStateNotAvailable():
            return CustomToast.success(t.appUpdate.notAvailableMsg)
                .show(context);
        }
      },
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          NestedAppBar(
            title: Text(t.about.pageTitle),
            actions: [
              PopupMenuButton(
                icon: Icon(AdaptiveIcon(context).more),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text(t.general.addToClipboard),
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: appInfo.format()),
                        );
                      },
                    ),
                  ];
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                // ═══════════════════════════════════════════════════════════
                // App Logo and Info
                // ═══════════════════════════════════════════════════════════
                FrostedContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avalanche Logo
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AvalancheTheme.iceBlue.withOpacity(0.3),
                                AvalancheTheme.glacierBlue.withOpacity(0.3),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            FluentIcons.mountain_location_bottom_20_filled,
                            size: 48,
                            color: AvalancheTheme.frostWhite,
                          ),
                        ),
                        const Gap(16),
                        // App Name
                        Text(
                          Constants.appName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AvalancheTheme.frostWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(4),
                        // Version
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AvalancheTheme.iceBlue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "v${appInfo.presentVersion}",
                            style: TextStyle(
                              color: AvalancheTheme.iceBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Gap(16),
                        // Tagline
                        Text(
                          'Secure. Private. Unstoppable.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AvalancheTheme.frostWhite.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Gap(24),
                
                // ═══════════════════════════════════════════════════════════
                // Actions Section
                // ═══════════════════════════════════════════════════════════
                if (appInfo.release.allowCustomUpdateChecker) ...[
                  _AboutTile(
                    icon: FluentIcons.arrow_sync_24_regular,
                    title: t.about.checkForUpdate,
                    trailing: switch (appUpdate) {
                      AppUpdateStateChecking() => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      _ => Icon(
                          FluentIcons.chevron_right_20_regular,
                          size: 20,
                          color: AvalancheTheme.frostWhite.withOpacity(0.4),
                        ),
                    },
                    onTap: () async {
                      await ref.read(appUpdateNotifierProvider.notifier).check();
                    },
                  ),
                ],
                
                if (PlatformUtils.isDesktop) ...[
                  _AboutTile(
                    icon: FluentIcons.folder_open_24_regular,
                    title: t.settings.general.openWorkingDir,
                    onTap: () async {
                      final path =
                          ref.watch(appDirectoriesProvider).requireValue.workingDir.uri;
                      await UriUtils.tryLaunch(path);
                    },
                  ),
                ],
                
                const Gap(16),
                
                // ═══════════════════════════════════════════════════════════
                // Links Section
                // ═══════════════════════════════════════════════════════════
                _SectionLabel('Links'),
                const Gap(8),
                
                _AboutTile(
                  icon: FluentIcons.code_24_regular,
                  title: t.about.sourceCode,
                  subtitle: 'GitHub Repository',
                  onTap: () async {
                    await UriUtils.tryLaunch(
                      Uri.parse(Constants.githubUrl),
                    );
                  },
                ),
                
                if (Constants.telegramChannelUrl.isNotEmpty)
                  _AboutTile(
                    icon: FluentIcons.chat_24_regular,
                    title: t.about.telegramChannel,
                    subtitle: 'Join our community',
                    onTap: () async {
                      await UriUtils.tryLaunch(
                        Uri.parse(Constants.telegramChannelUrl),
                      );
                    },
                  ),
                
                const Gap(16),
                
                // ═══════════════════════════════════════════════════════════
                // Legal Section
                // ═══════════════════════════════════════════════════════════
                _SectionLabel('Legal'),
                const Gap(8),
                
                if (Constants.termsAndConditionsUrl.isNotEmpty)
                  _AboutTile(
                    icon: FluentIcons.document_text_24_regular,
                    title: t.about.termsAndConditions,
                    onTap: () async {
                      await UriUtils.tryLaunch(
                        Uri.parse(Constants.termsAndConditionsUrl),
                      );
                    },
                  ),
                
                if (Constants.privacyPolicyUrl.isNotEmpty)
                  _AboutTile(
                    icon: FluentIcons.shield_24_regular,
                    title: t.about.privacyPolicy,
                    onTap: () async {
                      await UriUtils.tryLaunch(
                        Uri.parse(Constants.privacyPolicyUrl),
                      );
                    },
                  ),
                
                const Gap(24),
                
                // ═══════════════════════════════════════════════════════════
                // Credits
                // ═══════════════════════════════════════════════════════════
                Center(
                  child: Text(
                    'Built with ❄️ by the Avalanche team',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AvalancheTheme.frostWhite.withOpacity(0.5),
                    ),
                  ),
                ),
                
                const Gap(32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section label widget
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AvalancheTheme.iceBlue.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

/// About page tile with frosted glass styling
class _AboutTile extends StatelessWidget {
  const _AboutTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });
  
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AvalancheTheme.frostWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AvalancheTheme.frostWhite.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                trailing ?? Icon(
                  FluentIcons.open_24_regular,
                  size: 18,
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
