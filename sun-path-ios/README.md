# Sun Path — iPhone app

The native version of Sun Path. It works like the web version but uses what only a real app can:

- **Apple's true-north orientation** (Core Motion, the same fused compass + gyroscope that native AR apps use), so the overlay lines up from the start.
- **The camera's exact field of view**, read from the phone, so lines sit in the right place across the whole picture.
- Auto-alignment to the sun when it is in the camera view, tap-to-align, time travel, compare dates, solstice arcs, upcoming eclipses, photos (saved to Photos), English and Lithuanian. Everything works offline.

## Install on iPhone from a Windows PC (free Apple ID)

You need: the iPhone, its USB cable, a Windows PC, and your Apple ID.

1. **Download the app file.** Open the repository on GitHub → **Releases** → **Sun Path for iPhone** → download **SunPath.ipa**.
2. **Install iTunes and iCloud** from apple.com (the versions *from apple.com*, not the Microsoft Store — Sideloadly needs them to talk to the phone).
3. **Install Sideloadly** from <https://sideloadly.io> and open it.
4. **Connect the iPhone** with the cable. On the phone tap **Trust** and enter your passcode. It appears in Sideloadly.
5. **Drag SunPath.ipa** into Sideloadly, type your **Apple ID** email, and press **Start**. Enter your Apple ID password when asked (it is sent only to Apple). If you use two-factor authentication, type the code from your phone.
6. **Allow the app on the iPhone:** Settings → General → **VPN & Device Management** → your Apple ID → **Trust**.
7. **Turn on Developer Mode** (iOS 16 and newer): Settings → Privacy & Security → **Developer Mode** → on → restart → confirm.
8. Open **Sun Path**. Allow **Camera** and **Location** (choose *While Using the App*).

**Every 7 days** (Apple's limit for free accounts) the app stops opening. Connect the phone and press **Start** in Sideloadly again with the same file — your settings are kept.

## How it is built

`.github/workflows/sun-path-ios.yml` runs on a GitHub macOS runner: it generates the Xcode project from `project.yml` with XcodeGen, builds an unsigned app with `xcodebuild` and packages `SunPath.ipa`. Builds from `main` are published as the **sun-path-ios** release; builds from other branches are attached to the workflow run as an artifact. Sideloadly signs the app with your Apple ID when it installs it.

With a Mac you can instead run `xcodegen generate`, open `SunPath.xcodeproj`, choose your Apple ID under *Signing & Capabilities* and press Run.
