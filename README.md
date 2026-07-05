# Motivation Quotes

Daily motivational quotes app for Android & iOS — built with Flutter.

## Features

- **Quote mỗi ngày** — Daily quote based on date
- **Yêu thích** — Save favorites (15 free, unlimited via Shop)
- **Khám phá** — Browse 30+ quotes by category
- **Widget** — Home screen widget (Android)
- **Shop & Stars** — Earn stars or buy via Google Play
- **Themes, backgrounds, card skins** — Apply & reset to default
- **Premium features** — Fonts, export, notifications, no watermark

## IAP

- Prefix: `mq`
- Packs: `mq_pack_1` … `mq_pack_10`
- Remove ads: `mq_remove_ads`
- Remote config: `https://api2.blwsmartware.net/R211.json`

See [docs/IAP_GOOGLE_PLAY.md](docs/IAP_GOOGLE_PLAY.md) for Play Console setup.

## Run

```bash
flutter pub get
python tool/generate_logo.py
dart run flutter_launcher_icons
flutter run
```

## Package

`com.motivationquotesmng.motivationquotes`
