import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/goals_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import '../main_shell.dart';
import '../privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = '${info.version} (${info.buildNumber})');
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = context.watch<ThemeProvider>();
    final goals = context.watch<GoalsProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppStrings.t(context, 'settingsTitle')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(AppStrings.t(context, 'activeCustomization')),
          _InfoTile(
            icon: Icons.palette_outlined,
            title: AppStrings.t(context, 'activeTheme'),
            subtitle: AppStrings.t(context, _themeNameKey(shop.activeThemeId)),
          ),
          _InfoTile(
            icon: Icons.layers_outlined,
            title: AppStrings.t(context, 'activeBackground'),
            subtitle: AppStrings.t(context, _bgNameKey(shop.activeBackgroundId)),
          ),
          _InfoTile(
            icon: Icons.style_outlined,
            title: AppStrings.t(context, 'activeSkin'),
            subtitle: AppStrings.t(context, _skinNameKey(shop.activeSkinId)),
          ),
          const SizedBox(height: 16),
          _SectionTitle(AppStrings.t(context, 'appearance')),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text(AppStrings.t(context, 'darkMode')),
            value: theme.isDarkMode,
            onChanged: (_) => theme.toggleTheme(),
          ),
          if (shop.hasReminders)
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(AppStrings.t(context, 'shopFeatReminders')),
              subtitle: const Text('Reminders are active'),
              trailing: const Icon(Icons.check_circle_outline, color: AppColors.success),
            )
          else
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(AppStrings.t(context, 'shopFeatReminders')),
              subtitle: Text(AppStrings.t(context, 'widgetStylesLocked')),
              trailing: const Icon(Icons.lock_outline, size: 18),
              onTap: () => MainShell.of(context)?.openShop(),
            ),
          const SizedBox(height: 16),
          _SectionTitle(AppStrings.t(context, 'other')),
          ListTile(
            leading: const Icon(Icons.widgets_outlined),
            title: Text(AppStrings.t(context, 'widgetInfo')),
            subtitle: Text(AppStrings.t(context, 'widgetInfoDesc')),
          ),
          if (shop.hasWidgetStyles)
            ListTile(
              leading: Icon(Icons.style_outlined, color: Theme.of(context).colorScheme.primary),
              title: Text(AppStrings.t(context, 'shopFeatWidget')),
              subtitle: const Text('Choose widget style'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickWidgetStyle(shop, goals),
            )
          else
            ListTile(
              leading: const Icon(Icons.style_outlined),
              title: Text(AppStrings.t(context, 'shopFeatWidget')),
              subtitle: Text(AppStrings.t(context, 'widgetStylesLocked')),
              trailing: const Icon(Icons.lock_outline, size: 18),
              onTap: () => MainShell.of(context)?.openShop(),
            ),
          if (shop.hasExportGoals)
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: Text(AppStrings.t(context, 'shopFeatExportGoals')),
              subtitle: Text('${goals.goalCount} goals'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final json = goals.exportGoalsJson();
                Clipboard.setData(ClipboardData(text: json));
                AppToast.show(context, title: AppStrings.t(context, 'exportSuccess'), icon: Icons.check_circle_outline);
              },
            ),
          ListTile(
            leading: const Icon(Icons.stars_outlined),
            title: Text(AppStrings.t(context, 'openShop')),
            subtitle: Text(AppStrings.t(context, 'openShopDesc')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => MainShell.of(context)?.openShop(),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(AppStrings.t(context, 'privacyPolicy')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
          ),
          const SizedBox(height: 16),
          _SectionTitle(AppStrings.t(context, 'about')),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppStrings.t(context, 'version')),
            subtitle: Text(_version.isNotEmpty ? _version : '...'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(AppStrings.t(context, 'about')),
            subtitle: Text(AppStrings.t(context, 'aboutDesc')),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              AppStrings.t(context, 'copyright'),
              style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickWidgetStyle(ShopProvider shop, GoalsProvider goals) async {
    const styles = [
      ('default', 'Default (Gradient)', Icons.gradient),
      ('dark', 'Dark', Icons.dark_mode_outlined),
      ('minimal', 'Minimal', Icons.crop_square_outlined),
    ];
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text('Widget Style', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            ...styles.map((s) {
              final (id, label, icon) = s;
              return ListTile(
                leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
                title: Text(label),
                onTap: () async {
                  await goals.syncWidget(widgetStyle: id);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    AppToast.show(context, title: 'Widget style updated!', icon: Icons.widgets_rounded);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _themeNameKey(String id) => switch (id) {
        'theme_sunset' => 'shopThemeSunset',
        'theme_midnight' => 'shopThemeMidnight',
        'theme_tropical' => 'shopThemeTropical',
        'theme_sakura' => 'shopThemeSakura',
        _ => 'shopThemeSunset',
      };

  String _bgNameKey(String id) => switch (id) {
        'bg_sunrise' => 'shopBgSunrise',
        'bg_ocean' => 'shopBgOcean',
        'bg_aurora' => 'shopBgAurora',
        'bg_galaxy' => 'shopBgGalaxy',
        _ => 'shopBgSunrise',
      };

  String _skinNameKey(String id) => switch (id) {
        'skin_glass' => 'shopSkinGlass',
        'skin_minimal' => 'shopSkinMinimal',
        'skin_elegant' => 'shopSkinElegant',
        _ => 'shopSkinGlass',
      };
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.onSurfaceVariant)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    );
  }
}
