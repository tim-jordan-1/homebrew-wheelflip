# WheelFlip

WheelFlip is a macOS menu bar app that inverts mouse wheel scrolling. Your trackpad keeps its own scroll direction.

The app needs macOS 13 or later. It runs on Apple silicon and Intel Macs.

## Install with Homebrew

Run these two commands:

```bash
brew tap tim-jordan-1/wheelflip https://github.com/tim-jordan-1/WheelFlip
```

```bash
brew install --cask tim-jordan-1/wheelflip/wheelflip
```

WheelFlip is not notarized, which means that Apple did not scan this build. The cask removes the macOS quarantine flag from `WheelFlip.app` so that the app can open. If you do not trust this repository, do not install WheelFlip.

## Install from the zip file

1. Download `WheelFlip-1.0.zip` from the [releases page](https://github.com/tim-jordan-1/WheelFlip/releases).
2. Unzip the file.
3. Move `WheelFlip.app` to `/Applications`.
4. Run this command to remove the quarantine flag:

```bash
xattr -dr com.apple.quarantine /Applications/WheelFlip.app
```

## Build from source

You need the Xcode Command Line Tools. Run this command in the repository folder:

```bash
./build.sh
```

The script runs the tests, replaces `/Applications/WheelFlip.app`, and opens the app.

## Set up the app

1. Open WheelFlip from `/Applications`.
2. Open System Settings, then Privacy & Security, then Accessibility.
3. Turn on WheelFlip.
4. Make sure that the mouse icon is in the menu bar. This icon means that the app is active.
5. Optional: Click the menu bar icon, then click Open at Login.

WheelFlip inverts vertical scrolling by default. Use the menu bar icon to turn vertical or horizontal inversion on or off.

## Fix a warning icon

A triangle icon means that WheelFlip cannot change scroll events. Do these steps:

1. Open System Settings, then Privacy & Security, then Accessibility.
2. Select WheelFlip and remove it with the minus button.
3. Quit WheelFlip from the menu bar.
4. Open WheelFlip and turn it on again in Accessibility.

You must do these steps after each update of a Homebrew or zip file install. macOS links the Accessibility grant to the exact build of an ad-hoc signed app.

## Limits

WheelFlip changes only non-continuous scroll events. Most wheel mice send these events. The Magic Mouse and some smooth-scrolling mice send continuous events, and WheelFlip does not change them.

Do not run another scroll inverter at the same time. Two inverters cancel each other.

## Uninstall

If you installed with Homebrew, run this command:

```bash
brew uninstall --cask --zap wheelflip
```

If you installed in a different way, quit WheelFlip and delete `/Applications/WheelFlip.app`.

## License

WheelFlip uses the MIT License.
