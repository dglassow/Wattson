# TestFlight Release

Wattson is configured for Apple Developer Team `Z6ATGC7GNB`.

Use these values when creating the App Store Connect app record:

```text
Name: Wattson
Platform: iOS
Bundle ID: com.glassow.wattson
SKU: wattson-ios
Version: 1.0
Category: Lifestyle
Encryption: No non-exempt encryption
```

## Upload Build

1. Install full Xcode from the Mac App Store.
2. Open `Wattson.xcodeproj`.
3. In Xcode Settings, add the Apple ID that belongs to Team `Z6ATGC7GNB`.
4. Select the `Wattson` target and confirm **Signing & Capabilities** uses Team `Z6ATGC7GNB`.
5. Select **Any iOS Device** as the run destination.
6. Choose **Product > Archive**.
7. In Organizer, select the archive and choose **Distribute App**.
8. Choose **App Store Connect**, then upload.
9. After processing finishes in App Store Connect, open **TestFlight** and add yourself as an internal tester.
10. Install TestFlight on your iPhone and accept the invite.

## Before Public App Store Review

- Replace the placeholder icon with final artwork.
- Add final screenshots for iPhone and iPad.
- Fill in App Privacy in App Store Connect.
- Confirm whether live weather data will use WeatherKit or another provider.
