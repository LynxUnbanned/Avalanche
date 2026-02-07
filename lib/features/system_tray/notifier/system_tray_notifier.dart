import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:avalanche/core/localization/translations.dart';
import 'package:avalanche/core/model/constants.dart';
import 'package:avalanche/core/router/router.dart';
import 'package:avalanche/features/config_option/data/config_option_repository.dart';
import 'package:avalanche/features/connection/model/connection_status.dart';
import 'package:avalanche/features/connection/notifier/connection_notifier.dart';
import 'package:avalanche/features/proxy/active/active_proxy_notifier.dart';
import 'package:avalanche/features/proxy/overview/proxies_overview_notifier.dart';
import 'package:avalanche/features/window/notifier/window_notifier.dart';
import 'package:avalanche/gen/assets.gen.dart';
import 'package:avalanche/singbox/model/singbox_config_enum.dart';
import 'package:avalanche/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

part 'system_tray_notifier.g.dart';

@Riverpod(keepAlive: true)
class SystemTrayNotifier extends _$SystemTrayNotifier with AppLogger {
  @override
  Future<void> build() async {
    if (!PlatformUtils.isDesktop) return;

    final activeProxy = await ref.watch(activeProxyNotifierProvider);
    final delay = activeProxy.value?.urlTestDelay ?? 0;
    final serverName = activeProxy.value?.selectedName ?? activeProxy.value?.name;
    final newConnectionStatus = delay > 0 && delay < 65000;
    ConnectionStatus connection;
    try {
      connection = await ref.watch(connectionNotifierProvider.future);
    } catch (e) {
      loggy.warning("error getting connection status", e);
      connection = const ConnectionStatus.disconnected();
    }

    final t = ref.watch(translationsProvider);
    
    // Get IP info for copy functionality
    String? currentIp;
    try {
      final ipInfoAsync = ref.read(ipInfoNotifierProvider);
      if (ipInfoAsync case AsyncData(value: final info)) {
        currentIp = info.ip;
      }
    } catch (_) {}

    // Build enhanced tooltip with server info
    var tooltip = Constants.appName;
    final serviceMode = ref.watch(ConfigOptions.serviceMode);
    if (connection == Disconnected()) {
      setIcon(connection);
    } else if (newConnectionStatus) {
      setIcon(const Connected());
      tooltip = "$tooltip - ${connection.present(t)}";
      if (serverName != null && serverName.isNotEmpty) {
        tooltip = "$tooltip\n🌐 $serverName";
      }
      tooltip = "$tooltip\n⚡ ${delay}ms";
      if (currentIp != null) {
        tooltip = "$tooltip\n📍 $currentIp";
      }
    } else {
      setIcon(const Disconnecting());
      tooltip = "$tooltip - ${connection.present(t)}";
    }
    if (Platform.isMacOS) {
      windowManager.setBadgeLabel("${delay}ms");
    }
    if (!Platform.isLinux) await trayManager.setToolTip(tooltip);

    // Get available proxies for quick-connect submenu
    List<MenuItem> quickConnectItems = [];
    try {
      final proxiesAsync = ref.read(proxiesOverviewNotifierProvider);
      if (proxiesAsync case AsyncData(value: final groups)) {
        // Get first proxy group (usually the main selector)
        if (groups.isNotEmpty) {
          final mainGroup = groups.first;
          // Take top 8 servers sorted by delay
          final topServers = mainGroup.items
              .where((p) => !p.type.isGroup && p.urlTestDelay > 0 && p.urlTestDelay < 65000)
              .take(8)
              .toList();
          
          quickConnectItems = topServers.map((proxy) {
            final isActive = proxy.tag == mainGroup.selected;
            return MenuItem(
              label: "${isActive ? '✓ ' : ''}${proxy.tag} (${proxy.urlTestDelay}ms)",
              onClick: (_) async {
                await ref.read(proxiesOverviewNotifierProvider.notifier)
                    .changeProxy(mainGroup.tag, proxy.tag);
                // Auto-connect if not connected
                if (connection case Disconnected()) {
                  await ref.read(connectionNotifierProvider.notifier).toggleConnection();
                }
              },
            );
          }).toList();
        }
      }
    } catch (e) {
      loggy.debug("Could not load proxies for quick-connect: $e");
    }

    final menu = Menu(
      items: [
        MenuItem(
          label: t.tray.dashboard,
          onClick: (_) async {
            await ref.read(windowNotifierProvider.notifier).open();
          },
        ),
        MenuItem.separator(),
        
        // Connection status with server info
        MenuItem.checkbox(
          label: switch (connection) {
            Disconnected() => t.tray.status.connect,
            Connecting() => t.tray.status.connecting,
            Connected() => "${t.tray.status.disconnect}${serverName != null ? ' ($serverName)' : ''}",
            Disconnecting() => t.tray.status.disconnecting,
          },
          checked: false,
          disabled: connection.isSwitching,
          onClick: (_) async {
            await ref.read(connectionNotifierProvider.notifier).toggleConnection();
          },
        ),
        
        // Quick Connect submenu
        if (quickConnectItems.isNotEmpty) ...[
          MenuItem.submenu(
            label: "⚡ Quick Connect",
            submenu: Menu(items: quickConnectItems),
          ),
        ],
        
        // Copy IP Address option
        if (currentIp != null && connection is Connected) ...[
          MenuItem(
            label: "📋 Copy IP ($currentIp)",
            onClick: (_) async {
              await Clipboard.setData(ClipboardData(text: currentIp!));
            },
          ),
        ],
        
        MenuItem.separator(),
        MenuItem(
          label: t.config.serviceMode,
          icon: Assets.images.trayIconIco,
          disabled: true,
        ),

        ...ServiceMode.choices.map(
          (e) => MenuItem.checkbox(
            checked: e == serviceMode,
            key: e.name,
            label: e.present(t),
            onClick: (menuItem) async {
              final newMode = ServiceMode.values.byName(menuItem.key!);
              loggy.debug("switching service mode: [$newMode]");
              await ref.read(ConfigOptions.serviceMode.notifier).update(newMode);
            },
          ),
        ),

        MenuItem.separator(),
        MenuItem(
          label: t.tray.quit,
          onClick: (_) async {
            return ref.read(windowNotifierProvider.notifier).quit();
          },
        ),
      ],
    );

    await trayManager.setContextMenu(menu);
  }

  static void setIcon(ConnectionStatus status) {
    if (!PlatformUtils.isDesktop) return;
    trayManager
        .setIcon(
          _trayIconPath(status),
          isTemplate: Platform.isMacOS,
        )
        .asStream();
  }

  static String _trayIconPath(ConnectionStatus status) {
    if (Platform.isWindows) {
      final Brightness brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDarkMode = brightness == Brightness.dark;
      switch (status) {
        case Connected():
          return Assets.images.trayIconConnectedIco;
        case Connecting():
          return Assets.images.trayIconDisconnectedIco;
        case Disconnecting():
          return Assets.images.trayIconDisconnectedIco;
        case Disconnected():
          if (isDarkMode) {
            return Assets.images.trayIconIco;
          } else {
            return Assets.images.trayIconDarkIco;
          }
      }
    }
    final isDarkMode = false;
    switch (status) {
      case Connected():
        return Assets.images.trayIconConnectedPng.path;
      case Connecting():
        return Assets.images.trayIconDisconnectedPng.path;
      case Disconnecting():
        return Assets.images.trayIconDisconnectedPng.path;
      case Disconnected():
        if (isDarkMode) {
          return Assets.images.trayIconDarkPng.path;
        } else {
          return Assets.images.trayIconPng.path;
        }
    }
  }
}
