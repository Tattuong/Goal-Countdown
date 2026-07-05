class IapConstants {
  IapConstants._();

  static const String productPrefix = 'gc';

  static const String remoteConfigUrl = 'https://api2.blwsmartware.net/R220.json';

  static const Duration configTimeout = Duration(seconds: 10);

  static const List<String> coinPackIds = [
    'gc_pack_1',
    'gc_pack_2',
    'gc_pack_3',
    'gc_pack_4',
    'gc_pack_5',
    'gc_pack_6',
    'gc_pack_7',
    'gc_pack_8',
    'gc_pack_9',
    'gc_pack_10',
  ];

  static const String removeAdsProductId = 'gc_remove_ads';

  static List<String> get allProductIds => [...coinPackIds, removeAdsProductId];

  static const List<int> coinPackAmounts = [
    50,
    100,
    200,
    350,
    500,
    750,
    1000,
    1500,
    2200,
    3000,
  ];

  static int coinsForProduct(String productId) {
    final index = coinPackIds.indexOf(productId);
    if (index < 0) return 0;
    return coinPackAmounts[index];
  }

  static bool isRemoveAdsProduct(String productId) => productId == removeAdsProductId;

  static const int freeGoalLimit = 5;
  static const int dailyLoginReward = 10;
  static const int addGoalReward = 10;
  static const int maxAddGoalRewardsPerDay = 3;
  static const int shareGoalReward = 5;
  static const int maxShareRewardsPerDay = 3;
}
