import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:avalanche/core/localization/translations.dart';
import 'package:avalanche/features/common/nested_app_bar.dart';
import 'package:avalanche/features/settings/widgets/widgets.dart';
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
