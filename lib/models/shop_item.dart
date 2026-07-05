import 'package:flutter/material.dart';

enum ShopItemType {
  theme,
  background,
  skin,
  feature,
  removeAds,
}

enum ShopItemCategory {
  themes,
  backgrounds,
  skins,
  features,
  premium,
}

class ShopItem {
  final String id;
  final String nameKey;
  final String descKey;
  final int price;
  final ShopItemType type;
  final ShopItemCategory category;
  final IconData icon;
  final bool oneTime;

  const ShopItem({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.price,
    required this.type,
    required this.category,
    required this.icon,
    this.oneTime = true,
  });
}

class ShopCatalog {
  ShopCatalog._();

  static const String defaultThemeId = 'theme_default';
  static const String defaultBackgroundId = 'bg_default';
  static const String defaultSkinId = 'skin_default';

  static const List<ShopItem> items = [
    ShopItem(
      id: 'remove_ads',
      nameKey: 'shopRemoveAds',
      descKey: 'shopRemoveAdsDesc',
      price: 500,
      type: ShopItemType.removeAds,
      category: ShopItemCategory.premium,
      icon: Icons.block_outlined,
    ),
    ShopItem(
      id: 'theme_sunset',
      nameKey: 'shopThemeSunset',
      descKey: 'shopThemeSunsetDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.wb_twilight_outlined,
    ),
    ShopItem(
      id: 'theme_midnight',
      nameKey: 'shopThemeMidnight',
      descKey: 'shopThemeMidnightDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.nightlight_round,
    ),
    ShopItem(
      id: 'theme_tropical',
      nameKey: 'shopThemeTropical',
      descKey: 'shopThemeTropicalDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.forest_outlined,
    ),
    ShopItem(
      id: 'theme_sakura',
      nameKey: 'shopThemeSakura',
      descKey: 'shopThemeSakuraDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.local_florist_outlined,
    ),
    ShopItem(
      id: 'bg_sunrise',
      nameKey: 'shopBgSunrise',
      descKey: 'shopBgSunriseDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.wb_sunny_outlined,
    ),
    ShopItem(
      id: 'bg_ocean',
      nameKey: 'shopBgOcean',
      descKey: 'shopBgOceanDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.waves_outlined,
    ),
    ShopItem(
      id: 'bg_aurora',
      nameKey: 'shopBgAurora',
      descKey: 'shopBgAuroraDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.auto_awesome_outlined,
    ),
    ShopItem(
      id: 'bg_galaxy',
      nameKey: 'shopBgGalaxy',
      descKey: 'shopBgGalaxyDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.nightlight_outlined,
    ),
    ShopItem(
      id: 'skin_glass',
      nameKey: 'shopSkinGlass',
      descKey: 'shopSkinGlassDesc',
      price: 180,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.blur_on_outlined,
    ),
    ShopItem(
      id: 'skin_minimal',
      nameKey: 'shopSkinMinimal',
      descKey: 'shopSkinMinimalDesc',
      price: 150,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.crop_square_outlined,
    ),
    ShopItem(
      id: 'skin_elegant',
      nameKey: 'shopSkinElegant',
      descKey: 'shopSkinElegantDesc',
      price: 200,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.diamond_outlined,
    ),
    ShopItem(
      id: 'feat_unlimited_goals',
      nameKey: 'shopFeatUnlimitedGoals',
      descKey: 'shopFeatUnlimitedGoalsDesc',
      price: 300,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.track_changes_outlined,
    ),
    ShopItem(
      id: 'feat_reminders',
      nameKey: 'shopFeatReminders',
      descKey: 'shopFeatRemindersDesc',
      price: 250,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.notifications_active_outlined,
    ),
    ShopItem(
      id: 'feat_export_goals',
      nameKey: 'shopFeatExportGoals',
      descKey: 'shopFeatExportGoalsDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.file_download_outlined,
    ),
    ShopItem(
      id: 'feat_widget_styles',
      nameKey: 'shopFeatWidget',
      descKey: 'shopFeatWidgetDesc',
      price: 180,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.widgets_outlined,
    ),
    ShopItem(
      id: 'feat_custom_icons',
      nameKey: 'shopFeatCustomIcons',
      descKey: 'shopFeatCustomIconsDesc',
      price: 150,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.emoji_emotions_outlined,
    ),
    ShopItem(
      id: 'feat_no_watermark',
      nameKey: 'shopFeatNoWatermark',
      descKey: 'shopFeatNoWatermarkDesc',
      price: 150,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.image_not_supported_outlined,
    ),
  ];

  static ShopItem? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
