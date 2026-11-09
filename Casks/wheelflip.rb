cask "wheelflip" do
  version "1.1"
  sha256 "93a1438a598706195424762ca336151c06e58f4693b8e89aace5d84d3fc6864e"

  url "https://github.com/tim-jordan-1/homebrew-wheelflip/releases/download/v#{version}/WheelFlip-#{version}.zip"
  name "WheelFlip"
  desc "Invert mouse wheel scrolling without changing the trackpad"
  homepage "https://github.com/tim-jordan-1/homebrew-wheelflip"

  depends_on macos: :ventura

  app "WheelFlip.app"

  # The app is ad-hoc signed and not notarized, so Gatekeeper blocks it while the quarantine flag is present.
  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-dr", "com.apple.quarantine", "{{appdir}}/WheelFlip.app"],
        must_succeed: false
  end

  uninstall quit: "com.timjordan.WheelFlip"

  zap trash: "~/Library/Preferences/com.timjordan.WheelFlip.plist"
end
