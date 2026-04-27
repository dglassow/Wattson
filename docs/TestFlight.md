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

## TestFlight Without USB

Without USB, do not use Xcode's development signing flow. It requires a registered iPhone or iPad.

Instead, create an App Store distribution profile:

1. Go to `developer.apple.com/account`.
2. Open **Certificates, Identifiers & Profiles**.
3. Create or confirm this App ID:
   - Platform: iOS
   - Bundle ID: `com.glassow.wattson`
4. Create an **Apple Distribution** certificate if one does not exist.
5. Create a new provisioning profile:
   - Type: **App Store**
   - App ID: `com.glassow.wattson`
   - Certificate: your Apple Distribution certificate
   - Profile Name: `Wattson App Store`
6. Download the profile and double-click it to install in Xcode.
7. In Xcode, select **Any iOS Device** and choose **Product > Archive**.

The Release configuration is set to manual signing with provisioning profile `Wattson App Store`.

## Fix Signing Profiles

If Xcode says no provisioning profiles were found for `com.glassow.wattson`:

1. Open Xcode **Settings > Accounts**.
2. Add the Apple ID for Team `Z6ATGC7GNB`.
3. Select the account, choose the team, then open **Manage Certificates**.
4. Add an **Apple Development** certificate if one is missing.
5. Add an **Apple Distribution** certificate if one is missing.
6. Open the Wattson target, then **Signing & Capabilities**.
7. Confirm **Automatically manage signing** is enabled.
8. Confirm **Team** is `Z6ATGC7GNB`.
9. If Xcode still cannot create the profile, create the App ID manually at `developer.apple.com/account`:
   - Identifier type: App IDs
   - Type: App
   - Description: Wattson
   - Bundle ID: Explicit, `com.glassow.wattson`
10. Return to Xcode and click **Try Again** on the signing error.

If Xcode says the team has no devices:

- For direct device testing, connect an iPhone or iPad, unlock it, trust the Mac, enable Developer Mode if prompted, then choose the device in Xcode. Xcode can register the device and create a development profile.
- For TestFlight, use **Product > Archive** with **Any iOS Device** selected. TestFlight uses distribution signing and does not require registering your phone as a development device.
- To register a device manually, go to `developer.apple.com/account` and add the device UDID under **Certificates, Identifiers & Profiles > Devices**.

## Before Public App Store Review

- Replace the placeholder icon with final artwork.
- Add final screenshots for iPhone and iPad.
- Fill in App Privacy in App Store Connect.
- Confirm whether live weather data will use WeatherKit or another provider.
