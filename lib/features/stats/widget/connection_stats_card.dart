import 'dart:async';
import 'dart:ui';
import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:avalanche/core/localization/translations.dart';
import 'package:avalanche/core/theme/glassmorphism.dart';
import 'package:avalanche/core/widget/shimmer_skeleton.dart';
import 'package:avalanche/features/connection/model/connection_status.dart';
import 'package:avalanche/features/connection/notifier/connection_notifier.dart';
import 'package:avalanche/features/proxy/active/active_proxy_notifier.dart';
import 'package:avalanche/features/proxy/active/ip_widget.dart';
import 'package:avalanche/features/proxy/model/proxy_failure.dart';
import 'package:avalanche/features/stats/model/stats_entity.dart';
import 'package:avalanche/features/stats/notifier/stats_notifier.dart';
import 'package:avalanche/utils/number_formatters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ConnectionStatsCard extends HookConsumerWidget {
  const ConnectionStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final glassTheme = Theme.of(context).extension<GlassmorphismTheme>() ??
        GlassmorphismTheme.dark;
    final theme = Theme.of(context);

    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final ipInfo = ref.watch(ipInfoNotifierProvider);
    final connectionStatus = ref.watch(connectionNotifierProvider);
    final stats = ref.watch(statsNotifierProvider).asData?.value ?? StatsEntity.empty();

    // Session timer
    final sessionStartTime = useState<DateTime?>(null);
    final sessionDuration = useState<Duration>(Duration.zero);
    
    // Update session timer when connection changes
    useEffect(() {
      final sub = connectionStatus.whenData((status) {
        if (status is Connected && sessionStartTime.value == null) {
          sessionStartTime.value = DateTime.now();
        } else if (status is Disconnected) {
          sessionStartTime.value = null;
          sessionDuration.value = Duration.zero;
        }
      });
      return null;
    }, [connectionStatus]);

    // Timer to update session duration
    useEffect(() {
      if (sessionStartTime.value != null) {
        final timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (sessionStartTime.value != null) {
            sessionDuration.value = DateTime.now().difference(sessionStartTime.value!);
          }
        });
        return timer.cancel;
      }
      return null;
    }, [sessionStartTime.value]);

    final isConnected = connectionStatus.asData?.value is Connected;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: glassTheme.glassColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: glassTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: glassTheme.glowColor.withOpacity(isConnected ? 0.15 : 0.05),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    isConnected 
                        ? FluentIcons.plug_connected_20_filled
                        : FluentIcons.plug_disconnected_20_regular,
                    color: isConnected ? Colors.green : theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.stats.connection,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Session timer
                  if (isConnected) ...[
                    Icon(
                      FluentIcons.timer_20_regular,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(sessionDuration.value),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              
              // Server info row
              _StatRow(
                icon: FluentIcons.arrow_routing_20_regular,
                label: "Server",
                value: switch (activeProxy) {
                  AsyncData(value: final proxy) => proxy.selectedName.isNotNullOrBlank
                      ? proxy.selectedName!
                      : proxy.name,
                  _ => "...",
                },
              ),
              const SizedBox(height: 8),
              
              // IP info row  
              _buildIpRow(context, ref, ipInfo, t),
              
              // Speed stats (only when connected)
              if (isConnected) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Speed indicators
                Row(
                  children: [
                    Expanded(
                      child: _SpeedIndicator(
                        label: "↓ Download",
                        speed: stats.downlink.speed(),
                        total: stats.downlinkTotal.size(),
                        color: const Color(0xFF4FC3F7),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SpeedIndicator(
                        label: "↑ Upload",
                        speed: stats.uplink.speed(),
                        total: stats.uplinkTotal.size(),
                        color: const Color(0xFF81C784),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIpRow(BuildContext context, WidgetRef ref, AsyncValue ipInfo, TranslationsEn t) {
    return switch (ipInfo) {
      AsyncData(value: final info) => _StatRow(
          icon: null,
          flagWidget: IPCountryFlag(countryCode: info.countryCode, size: 18),
          label: "IP",
          valueWidget: IPText(
            ip: info.ip,
            onLongPress: () => ref.read(ipInfoNotifierProvider.notifier).refresh(),
            constrained: true,
          ),
        ),
      AsyncLoading() => const _StatRow(
          icon: FluentIcons.question_circle_20_regular,
          label: "IP",
          valueWidget: ShimmerSkeleton(widthFactor: 0.5, height: 14),
        ),
      AsyncError(error: final UnknownIp _) => _StatRow(
          icon: FluentIcons.arrow_sync_20_regular,
          label: "IP",
          valueWidget: UnknownIPText(
            text: t.proxies.checkIp,
            onTap: () => ref.read(ipInfoNotifierProvider.notifier).refresh(),
            constrained: true,
          ),
        ),
      _ => _StatRow(
          icon: FluentIcons.error_circle_20_regular,
          label: "IP",
          valueWidget: UnknownIPText(
            text: t.proxies.unknownIp,
            onTap: () => ref.read(ipInfoNotifierProvider.notifier).refresh(),
            constrained: true,
          ),
        ),
    };
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    this.icon,
    this.flagWidget,
    required this.label,
    this.value,
    this.valueWidget,
  });

  final IconData? icon;
  final Widget? flagWidget;
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        if (flagWidget != null)
          flagWidget!
        else if (icon != null)
          Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const Spacer(),
        if (valueWidget != null)
          Flexible(child: valueWidget!)
        else
          Text(
            value ?? "",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _SpeedIndicator extends StatelessWidget {
  const _SpeedIndicator({
    required this.label,
    required this.speed,
    required this.total,
    required this.color,
  });

  final String label;
  final String speed;
  final String total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  speed,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  total,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
