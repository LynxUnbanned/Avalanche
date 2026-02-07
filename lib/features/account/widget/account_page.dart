import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:avalanche/core/localization/translations.dart';
import 'package:avalanche/core/theme/avalanche_theme.dart';
import 'package:avalanche/core/widget/frosted_container.dart';
import 'package:avalanche/features/common/nested_app_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

/// Account page displaying user subscription status and usage information.
/// Currently shows placeholder data until Supabase integration is complete.
class AccountPage extends HookConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final theme = Theme.of(context);
    
    // TODO: Replace with real data from Supabase when integrated
    const isLoggedIn = true; // Placeholder - will be from auth state
    const userEmail = 'user@example.com';
    const subscriptionTier = 'Premium';
    const daysRemaining = 28;
    const dataUsedGB = 45.2;
    const dataTotalGB = 100.0;
    const hoursConnected = 156;
    const minutesConnected = 32;

    return Scaffold(
      body: Stack(
        children: [
          // Winter background would go here via WinterBackground widget
          CustomScrollView(
            slivers: [
              NestedAppBar(
                title: Text('Account', style: theme.textTheme.headlineSmall),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // User Profile Card
                    FrostedContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AvalancheTheme.iceBlue,
                                        AvalancheTheme.auroraPurple,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Icon(
                                    FluentIcons.person_24_filled,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const Gap(16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userEmail,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: AvalancheTheme.frostWhite,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Gap(4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AvalancheTheme.iceBlue.withOpacity(0.3),
                                              AvalancheTheme.auroraPurple.withOpacity(0.3),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AvalancheTheme.iceBlue.withOpacity(0.5),
                                          ),
                                        ),
                                        child: Text(
                                          subscriptionTier,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: AvalancheTheme.iceBlue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Gap(16),
                    
                    // Subscription Status Card
                    FrostedContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  FluentIcons.calendar_24_filled,
                                  color: AvalancheTheme.iceBlue,
                                  size: 20,
                                ),
                                const Gap(8),
                                Text(
                                  'Subscription Status',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: AvalancheTheme.frostWhite.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$daysRemaining days remaining',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: AvalancheTheme.frostWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    'Active',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Gap(16),
                    
                    // Data Usage Card
                    FrostedContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  FluentIcons.arrow_download_24_filled,
                                  color: AvalancheTheme.iceBlue,
                                  size: 20,
                                ),
                                const Gap(8),
                                Text(
                                  'Data Usage',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: AvalancheTheme.frostWhite.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                            LinearPercentIndicator(
                              lineHeight: 12,
                              percent: dataUsedGB / dataTotalGB,
                              backgroundColor: AvalancheTheme.deepNavy,
                              linearGradient: LinearGradient(
                                colors: [
                                  AvalancheTheme.iceBlue,
                                  AvalancheTheme.auroraPurple,
                                ],
                              ),
                              barRadius: const Radius.circular(6),
                              padding: EdgeInsets.zero,
                            ),
                            const Gap(12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${dataUsedGB.toStringAsFixed(1)} GB used',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AvalancheTheme.frostWhite,
                                  ),
                                ),
                                Text(
                                  '${dataTotalGB.toStringAsFixed(0)} GB total',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AvalancheTheme.frostWhite.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Gap(16),
                    
                    // Connection Time Card
                    FrostedContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  FluentIcons.clock_24_filled,
                                  color: AvalancheTheme.iceBlue,
                                  size: 20,
                                ),
                                const Gap(8),
                                Text(
                                  'Connection Time This Period',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: AvalancheTheme.frostWhite.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                            Row(
                              children: [
                                _TimeBlock(value: hoursConnected.toString(), label: 'hours'),
                                const Gap(8),
                                Text(
                                  ':',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: AvalancheTheme.frostWhite.withOpacity(0.5),
                                  ),
                                ),
                                const Gap(8),
                                _TimeBlock(value: minutesConnected.toString().padLeft(2, '0'), label: 'minutes'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Gap(24),
                    
                    // Logout Button
                    FrostedContainer(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: Implement logout with Supabase
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Logout will be available after Supabase integration'),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FluentIcons.sign_out_24_filled,
                                  color: Colors.red.shade300,
                                  size: 20,
                                ),
                                const Gap(8),
                                Text(
                                  'Log Out',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.red.shade300,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const Gap(32),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({required this.value, required this.label});
  
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: AvalancheTheme.frostWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AvalancheTheme.frostWhite.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
