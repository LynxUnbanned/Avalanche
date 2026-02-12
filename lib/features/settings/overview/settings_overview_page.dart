import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/settings/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsOverviewPage extends HookConsumerWidget {
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          NestedAppBar(
            title: Text(t.settings.pageTitle),
          ),
          SliverList.list(
            children: [
              SettingsSection(t.settings.general.sectionTitle),
              const GeneralSettingTiles(),
              const PlatformSettingsTiles(),
              const SettingsDivider(),
              const SettingsSection("Avalanche"),
              ListTile(
                title: const Text("Protocols"),
                subtitle: const Text("Choose protocols, rename protocol labels, run delay tests"),
                leading: const Icon(FluentIcons.filter_24_regular),
                onTap: () => const SettingsProtocolsRoute().push(context),
              ),
              ListTile(
                title: const Text("Config Options"),
                subtitle: const Text("All connection and routing options"),
                leading: const Icon(FluentIcons.box_edit_24_regular),
                onTap: () => const SettingsConfigOptionsRoute().push(context),
              ),
              ListTile(
                title: const Text("Logs"),
                subtitle: const Text("View and filter runtime logs"),
                leading: const Icon(FluentIcons.document_text_24_regular),
                onTap: () => const SettingsLogsRoute().push(context),
              ),
              ListTile(
                title: const Text("About"),
                subtitle: const Text("Application metadata and source repository"),
                leading: const Icon(FluentIcons.info_24_regular),
                onTap: () => const SettingsAboutRoute().push(context),
              ),
              ListTile(
                title: const Text("Account"),
                subtitle: const Text("Supabase account status and authentication"),
                leading: const Icon(FluentIcons.person_24_regular),
                onTap: () => const SettingsAccountRoute().push(context),
              ),
              const SettingsDivider(),
              SettingsSection(t.settings.advanced.sectionTitle),
              const AdvancedSettingTiles(),
              const Gap(16),
            ],
          ),
        ],
      ),
    );
  }
}
