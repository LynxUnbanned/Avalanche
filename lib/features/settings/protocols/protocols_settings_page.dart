import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/proxy/overview/proxies_overview_notifier.dart';
import 'package:hiddify/singbox/model/singbox_proxy_type.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _protocolAliasPrefix = "protocol_alias_";

String _aliasKey(ProxyType type) => "$_protocolAliasPrefix${type.name}";

String _aliasFor(SharedPreferences prefs, ProxyType type) {
  final custom = prefs.getString(_aliasKey(type))?.trim();
  if (custom == null || custom.isEmpty) return type.label;
  return custom;
}

class ProtocolsSettingsPage extends HookConsumerWidget with PresLogger {
  const ProtocolsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final asyncPrefs = ref.watch(sharedPreferencesProvider);
    final asyncProxies = ref.watch(proxiesOverviewNotifierProvider);
    final notifier = ref.watch(proxiesOverviewNotifierProvider.notifier);
    final selectMutation = useMutation(
      initialOnFailure: (error) =>
          CustomToast.error(t.presentShortError(error)).show(context),
    );
    final aliasVersion = useState(0);

    Future<void> editAlias(
      SharedPreferences prefs,
      ProxyType type,
    ) async {
      final current = _aliasFor(prefs, type);
      final controller = TextEditingController(
        text: current == type.label ? "" : current,
      );
      final nextValue = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Rename ${type.label}"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Leave empty to use default name",
            ),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) =>
                Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      );
      controller.dispose();

      if (nextValue == null) return;
      if (nextValue.isEmpty) {
        await prefs.remove(_aliasKey(type));
      } else {
        await prefs.setString(_aliasKey(type), nextValue);
      }
      aliasVersion.value++;
    }

    Future<void> resetAliases(
      SharedPreferences prefs,
      Iterable<ProxyType> protocolTypes,
    ) async {
      for (final type in protocolTypes) {
        await prefs.remove(_aliasKey(type));
      }
      aliasVersion.value++;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          NestedAppBar(
            title: const Text("Protocols"),
            actions: [
              if (asyncPrefs case AsyncData(value: final prefs))
                IconButton(
                  tooltip: "Reset protocol labels",
                  onPressed: () async {
                    final protocolTypes = switch (asyncProxies) {
                      AsyncData(value: final groups) when groups.isNotEmpty =>
                        groups.first.items.map((item) => item.type).toSet(),
                      _ => <ProxyType>{},
                    };
                    await resetAliases(prefs, protocolTypes);
                  },
                  icon: const Icon(FluentIcons.arrow_reset_24_regular),
                ),
            ],
          ),
          switch ((asyncPrefs, asyncProxies)) {
            (AsyncLoading(), _) || (_, AsyncLoading()) =>
              const SliverLoadingBodyPlaceholder(),
            (AsyncError(:final error), _) =>
              SliverErrorBodyPlaceholder(t.presentShortError(error)),
            (_, AsyncError(:final error)) =>
              SliverErrorBodyPlaceholder(t.presentShortError(error)),
            (AsyncData(value: final prefs), AsyncData(value: final groups)) =>
              groups.isEmpty
                  ? const SliverBodyPlaceholder(
                      [
                        Text("No protocols available"),
                      ],
                    )
                  : (() {
                      final group = groups.first;
                      return SliverList.list(
                        children: [
                      ListTile(
                        title: const Text("Test protocols"),
                        subtitle: const Text(
                          "Run delay test for currently available protocol routes",
                        ),
                        leading: const Icon(FluentIcons.flash_24_filled),
                        onTap: () async => notifier.urlTest(group.tag),
                      ),
                      const Divider(height: 1),
                      ...group.items.map((proxy) {
                        final alias = _aliasFor(prefs, proxy.type);
                        final delay = proxy.urlTestDelay;
                        final delayText = delay == 0
                            ? "Testing..."
                            : delay > 65000
                                ? "Timeout"
                                : "${delay} ms";
                        return ListTile(
                          title: Text(
                            proxy.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            "$alias (${proxy.type.label})",
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(delayText),
                          selected: group.selected == proxy.tag,
                          onTap: () async {
                            if (selectMutation.state.isInProgress) return;
                            selectMutation.setFuture(
                              notifier.changeProxy(group.tag, proxy.tag),
                            );
                          },
                        );
                      }),
                      const Divider(height: 1),
                      const ListTile(
                        title: Text("Rename protocols"),
                        subtitle: Text(
                          "Custom names are display-only. Real protocol behavior does not change.",
                        ),
                      ),
                      ...(() {
                        final protocolTypes = group.items
                            .map((item) => item.type)
                            .toSet()
                            .toList()
                          ..sort((a, b) => a.label.compareTo(b.label));
                        return protocolTypes.map(
                            (type) => ListTile(
                              key: ValueKey(
                                "${type.name}-${aliasVersion.value}",
                              ),
                              leading: const Icon(
                                FluentIcons.text_change_case_24_regular,
                              ),
                              title: Text(type.label),
                              subtitle: Text(_aliasFor(prefs, type)),
                              trailing: const Icon(
                                FluentIcons.edit_24_regular,
                              ),
                              onTap: () async => editAlias(prefs, type),
                            ),
                          );
                      })(),
                    ],
                      );
                    })(),
            _ => const SliverToBoxAdapter(),
          },
        ],
      ),
    );
  }
}
